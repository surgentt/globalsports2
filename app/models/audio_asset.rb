require 'net/http'

class AudioAsset < ActiveRecord::Base

  STATUS_NEW      = 'new'
  STATUS_PULLING  = 'pulling'
  STATUS_PULLED   = 'pulled'
  STATUS_PUSHING  = 'pushing'
  STATUS_READY    = 'ready'
  STATUS_ERROR    = 'error'

  belongs_to :user
  has_many :audio_timelines, :through => :audio_timeline_assets

  named_scope :for_user, lambda { |user_id| { :conditions => {:user_id=>user_id} }  }


  def local_file_name()
    "#{id}.flv"
  end

  def pull()

    self.status= STATUS_PULLING
    self.save!

    FileUtils.makedirs UPLOAD_BASE if ! File.exists?(UPLOAD_BASE)

    Net::HTTP.start(AUDIO_SERVER, AUDIO_SERVER_PORT) { |http|
      resp = http.get("#{AUDIO_SERVER_URI}#{local_file_name()}")
      open("#{UPLOAD_BASE}#{local_file_name()}", "wb") { |file|
        file.write(resp.body)
       }
    }

    self.status= STATUS_PULLED
    self.save!
  end

  def self.sanitize_filename(filename)
    name = filename.strip
    # Filename only no path
    name.gsub! /^.*(\\|\/)/, ''
    # replace all non alphanumeric, underscore or periods with underscore
    name.gsub! /[^\w\.\-]/, '_'

    # Remove multiple underscores
    name.gsub!(/\_+/, '_')

    name
  end



  def push()

    self.status= STATUS_PUSHING
    self.save!

    vidavee = Vidavee.find(:first)
    login = vidavee.login
    raise Exception.new( "Cannot log into vidavee back end" ) if login.nil?

    #TODO get it from red5 server

   
    dockey = vidavee.push_audio login, self, "#{UPLOAD_BASE}#{local_file_name()}"

    dockey

  end


  
  def xml_builder()    
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml
  end

  def to_xml(xml = xml_builder(), extra_attrs={})
#    xml.audioBite(:id=>self.id) {
#      xml.uploadedOn(self.created_at)
#      xml.status(self.status)
#      xml.length(self.length)
#    }

    attrs = {
      :id=>self.id,
      :status=>self.status,
      :length=>self.length,
      :dockey=>self.dockey
    }.merge!(extra_attrs)
    
    xml.audioBite(attrs) {
      xml.created_at(self.created_at)
    }
  end




end