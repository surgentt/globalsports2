class V4AssetsController < BaseController
  # GET /v4_assets
  # GET /v4_assets.xml
  def index
    @v4_assets = V4Asset.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @v4_assets }
    end
  end

  # GET /v4_assets/1
  # GET /v4_assets/1.xml
  def show
    @v4_asset = V4Asset.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @v4_asset }
    end
  end

  # GET /v4_assets/new
  # GET /v4_assets/new.xml
  def new
    @v4_asset = V4Asset.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @v4_asset }
    end
  end

  # GET /v4_assets/1/edit
  def edit
    @v4_asset = V4Asset.find(params[:id])
  end

  # POST /v4_assets
  # POST /v4_assets.xml
  def create
    @v4_asset = V4Asset.new(params[:v4_asset])

    respond_to do |format|
      if @v4_asset.save
        flash[:notice] = 'V4Asset was successfully created.'
        format.html { redirect_to(@v4_asset) }
        format.xml  { render :xml => @v4_asset, :status => :created, :location => @v4_asset }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @v4_asset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /v4_assets/1
  # PUT /v4_assets/1.xml
  def update
    @v4_asset = V4Asset.find(params[:id])

    respond_to do |format|
      if @v4_asset.update_attributes(params[:v4_asset])
        flash[:notice] = 'V4Asset was successfully updated.'
        format.html { redirect_to(@v4_asset) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @v4_asset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /v4_assets/1
  # DELETE /v4_assets/1.xml
  def destroy
    @v4_asset = V4Asset.find(params[:id])
    @v4_asset.destroy

    respond_to do |format|
      format.html { redirect_to(v4_assets_url) }
      format.xml  { head :ok }
    end
  end
end
