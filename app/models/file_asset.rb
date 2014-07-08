
require 'digest/md5'

class FileAsset < ActiveRecord::Base

  belongs_to :user
  belongs_to :asset, :polymorphic => true

  STATUS_OPEN = 'open'
  STATUS_UP   = 'up'

  AllowedTypes = [nil, 'null', 'VideoAsset', 'VideoUser', 'AudioAsset']

  validates_inclusion_of :asset_type, :in =>AllowedTypes, :message => "%{value} is not a valid Asset Type"

  #if AllowedTypes.include? video_type


  ### Constructors ###

  def self.open(params)
    file_asset = FileAsset.new()

    file_asset.name           = params[:name]
    file_asset.block_count    = params[:block_count]
    file_asset.status         = FileAsset::STATUS_OPEN
    file_asset.set_location()
    file_asset.agent          = params[:agent]

    file_asset.asset_type     = params[:asset_type]
    file_asset.asset_id       = params[:asset_id]

    file_asset.save!

    return file_asset
  end


  def self.copy(file,filename)
    FileUtils.makedirs UPLOAD_BASE if ! File.exists?(UPLOAD_BASE)

    file_asset = FileAsset.new()

    file_asset.name           = filename
    file_asset.block_count    = 1
    file_asset.status         = FileAsset::STATUS_OPEN
    file_asset.set_location()
    file_asset.save!

    FileUtils.mv(file.path,file_asset.full_path)

    file_asset.last_block     = 1
    file_asset.finish()

    return file_asset
  end


  ########################


  def set_location()
    name = self.name
    if name
      name.strip!
      name.gsub! /^.*(\\|\/)/, ''
      name.gsub! /[^\w\.\-]/, '_'
      name.gsub!(/\_+/, '_')
    else
      name = 'na'
    end
    self.location = "#{Time.now.to_i}-#{name}"
  end

  def full_path()
      "#{UPLOAD_BASE}#{self.location()}"
  end



  def finish()

    self.status = FileAsset::STATUS_UP

    #TODO: we don't need this overhead live?
    self.stat()

    self.save!
    
    self.attach_asset()

  end

  def stat()
    #self.md5 = Digest::MD5.hexdigest(open(self.full_path(),"rb"){|f| f.read}) rescue '-mdfail-'

    #self.md5 = `md5 -q #{self.full_path()}`.chomp rescue '-mdfail-'

    begin
      md5 = Digest::MD5.new()
      file = File.open(self.full_path(), 'r')
      file.each_line do |line|
        md5 << line
      end
      self.md5 = md5.hexdigest
    rescue Exception=>e
      self.md5 = '-mdfail-'
      logger.error("Message for the log file #{e.message}")
    end


    self.size = File.size(self.full_path())
  end


  def associate(asset_type,asset_id)
    logger.info("FileAsset.associate(#{asset_type},#{asset_id})")
    self.asset_type = asset_type;
    self.asset_id   = asset_id;

    self.save!

    self.attach_asset()
  end

  def attach_asset()

    self.reload()

    logger.info("FileAsset.attach_asset()")
    #asset = asset_type.constantize.find(asset_id) if AllowedTypes.include? video_type
    if asset && asset.respond_to?(:uploaded_file_path)
      logger.info("FileAsset.attach_asset(): found asset")
      asset.uploaded_file_path = self.full_path();
      asset.video_status = 'saving';
      asset.save!
    end
  end

end

