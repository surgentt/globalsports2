class SeriesController < BaseController

  skip_before_filter :gs_login_required, :only => [:show]



  def index


  end


  def show
    @series = Series.find(params[:id])

    @series_video_id = params[:series_video_id] || @series.feature.id

    @video = SeriesVideo.find(@series_video_id)


  end

end