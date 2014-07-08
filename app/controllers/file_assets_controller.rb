
require 'base64'

class FileAssetsController < BaseController

  skip_before_filter :verify_authenticity_token, :only => [:append, :upload ]

  skip_before_filter :gs_login_required, :only => [ :upload ]


  def append

    write_mode = 'a'
    @file_asset = nil
    block_no = nil
    block = nil

    t1 = Time.now()

    if(params[:id])
      @file_asset = FileAsset.find(params[:id])
    else
      write_mode = 'w'
      @file_asset = FileAsset.open(params)
      @file_asset.user = current_user
    end

    block_no = params[:block_no].to_i
    block    = params[:block]

    t2 = Time.now()

    bytes = Base64.decode64(block)
    written = 0

    t3 = Time.now()

    File.open(@file_asset.full_path(), write_mode){ |file|
      written = file.write(bytes)
    }

    t4 = Time.now()

    #TODO check last block for dups
    @file_asset.last_block = block_no
    @file_asset.save!

    next_block = block_no + 1

    if next_block > @file_asset.block_count
      next_block = -1
      @file_asset.finish()
    end

    render :text => {
          :id => @file_asset.id,
          :status => 'ok',
          :next_block => next_block,
          :bytes_written => written,
            :t12 => t2 - t1,
            :t23 => t3 - t2,
            :t34 => t4 - t3
        }.to_json

  end




  def index
    @file_assets = FileAsset.find(:all, :order => 'id desc')
    render :action => :index
  end


  def show
    @file_asset = FileAsset.find(params[:id])

  end


  def new
    @file_asset = FileAsset.new

  end


  def edit
    @file_asset = FileAsset.find(params[:id])
  end


  def create
    @file_asset = FileAsset.new(params[:file_asset])

    @file_asset.user = current_user

    respond_to do |format|
      if @file_asset.save
        flash[:notice] = 'FileAsset was successfully created.'
        format.html { redirect_to(@file_asset) }
        format.xml  { render :xml => @file_asset, :status => :created, :location => @file_asset }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @file_asset.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @file_asset = FileAsset.find(params[:id])

    respond_to do |format|
      if @file_asset.update_attributes(params[:file_asset])
        flash[:notice] = 'FileAsset was successfully updated.'
        format.html { redirect_to(@file_asset) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @file_asset.errors, :status => :unprocessable_entity }
      end
    end
  end


  def destroy
    @file_asset = FileAsset.find(params[:id])
    @file_asset.destroy
    render :text => ''
#    respond_to do |format|
#      format.html { redirect_to(file_assets_url) }
#      format.xml  { head :ok }
#    end
  end

  def upload
    file = params[:Filedata]
    filename = params[:Filename]

    @file_asset = FileAsset.copy(file,filename)

    @file_asset.user = current_user

    @file_asset.agent = params[:agent]
    @file_asset.associate(params[:asset_type],params[:asset_id])

    render :text => 'OK'
  end




end
