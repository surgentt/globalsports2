class CameraSitesController < BaseController

  before_filter :admin_required, :only => [:index, :show, :edit, :update, :destroy]
  skip_before_filter :gs_login_required, :only => [:new, :create]


  def home
    redirect '/'
  end

  def index
    @camera_sites = CameraSite.paginate(:all, :order => 'id desc', :page => params[:page])
  end

  def show
    @camera_site = CameraSite.find(params[:id])
  end

  def new
    @camera_site = CameraSite.new
    @camera_site.brand = params[:brand]
  end

  def edit
    @camera_site = CameraSite.find(params[:id])
  end

  def create
    @camera_site = CameraSite.new(params[:camera_site])

    if @camera_site.save
      render :action => 'thanks'
    else
      render :action => 'new'
    end

  end

  def update
    @camera_site = CameraSite.find(params[:id])

    if @camera_site.update_attributes(params[:camera_site])
      render :action => 'thanks'
    else
      render :action => 'edit'
    end

  end

  def destroy
    @camera_site = CameraSite.find(params[:id])
    @camera_site.destroy

    redirect_to(camera_sites_url)
  end

end
