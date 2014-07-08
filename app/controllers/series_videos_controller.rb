class SeriesVideosController < BaseController

  #skip_before_filter :gs_login_required, :only => [:pull]



  def pull
    video = SeriesVideo.find(:first, :conditions=>{:media_id => params[:id]})

    unless video
      render :text => 'NOID'
      return
    end

    #url = "http://#{@video.series.host_key}.video4ever.net/sportzcast.aspx?cmd=getmeta&id=#{@video.media_id}"
    #doc = Hpricot(open(url).read)
    #
    #(doc/:metadata/:event).each { |event|
    #  @video.title = event[:title]
    #  @video.time = event[:time]
    #  @video.sport = event[:sport]
    #
    #  @video.save!
    #}

    c = video.pull!

    render :text => 'OK'

  end

  def stat
    video = SeriesVideo.find(:first, :conditions=>{:media_id => params[:id]})

    unless video
      render :text => 'NOID'
      return
    end

    video.status = params[:status]
    c = video.save!

    render :text => 'OK'

  end


end