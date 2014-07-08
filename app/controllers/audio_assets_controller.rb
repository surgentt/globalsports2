class AudioAssetsController < BaseController


  skip_before_filter :verify_authenticity_token, :only => [:get_next]

  before_filter :admin_required, :only => [:admin ]

  #session :cookie_only => false, :only => [:swfupload]

  skip_before_filter :gs_login_required, :only => [ :show, :get_next, :commit, :get_timeline, :add_to_timeline, :clear_timeline, :remove_from_timeline ]

  sortable_attributes :id, :dockey, :title, :status, 'teams.name', 'leagues.name', 'users.lastname', :video_status

  def get_next
    @audio_asset = AudioAsset.new
    @audio_asset.status = AudioAsset::STATUS_NEW
    @audio_asset.user = current_user
    @audio_asset.save!

    #render :xml=>next_asset_xml(@audio_asset)

    #render_audioBite @audio_asset
    render :xml=>@audio_asset.to_xml()
  end

  def commit
    @audio_asset = AudioAsset.find(params[:id])

    updates = {
        :length => params[:length]
      }

    status = @audio_asset.update_attributes(updates)
    @audio_asset.save!

    @audio_asset.pull()

    #render_audioBite @audio_asset
    render :xml=>@audio_asset.to_xml()
  end

  def library
    @audio_assets = AudioAsset.for_user(current_user.id)

    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!

    render :xml=>xml.audioLibrary() {
        @audio_assets.each() {|asset|
          asset.to_xml(xml)
        }
      }
  end

  def get_timeline

    if params[:id]
      logger.debug "/audio_assets/get_timeline: by id"
      @audio_timeline = AudioTimeline.find(params[:id])
    elsif params[:dockey]
      logger.debug "/audio_assets/get_timeline: by dockey"
      @audio_timeline = AudioTimeline.for_dockey(params[:dockey])
#      video_asset = VideoAsset.find(:first, :conditions=>{:dockey=>params[:dockey]} )
#      logger.debug "/audio_assets/get_timeline: video_asset#{video_asset}"
#      begin
#        @audio_timeline = AudioTimeline.find(:first, :conditions=>{:video_asset_id=>video_asset.id} )
#        @audio_timeline.save!
#      rescue ActiveRecord::RecordNotFound
#        @audio_timeline = AudioTimeline.new
#        @audio_timeline.status = AudioAsset::STATUS_NEW
#        @audio_timeline.video_asset_id = video_asset.id
#        @audio_timeline.save!
#      end
    else
      logger.debug "/audio_assets/get_timeline: else"
      @audio_timeline = AudioTimeline.new
      @audio_timeline.user = current_user
      @audio_timeline.save!
    end

    logger.debug "/audio_assets/get_timeline: #{@audio_timeline.inspect}"
    #render_timeline @audio_timeline
    render :xml=>@audio_timeline.to_xml()
  end

  def add_to_timeline
    @audio_timeline = AudioTimeline.find(params[:id])

    if params[:bite_id]
      @audio_asset = AudioAsset.find(params[:bite_id])
      #@audio_asset.audio_timeline_id = @audio_timeline.id
      #@audio_asset.start_position = params[:position]
      #@audio_asset.save!

      join = AudioTimelineAsset.new({ :audio_timeline_id => @audio_timeline.id, :audio_asset_id => @audio_asset.id, :start_position => params[:position]  })
      join.save!

    end

    if params[:dockey]
      @audio_timeline.set_dockey(params[:dockey]) #video_asset_id = VideoAsset.find(:first, :conditions=>{ :dockey => params[:dockey] } ).id
      @audio_timeline.save!
    end
    
    #render_timeline @audio_timeline
    render :xml=>@audio_timeline.to_xml()
  end

  def remove_from_timeline
    @audio_timeline = AudioTimeline.find(params[:id])
    
    AudioTimelineAsset.for(@audio_timeline.id, params[:bite_id]).first.destroy()

    #@audio_asset = AudioAsset.find(params[:bite_id])
    #@audio_asset.audio_timeline_id = null
    #@audio_asset.save!

    #render_timeline @audio_timeline
    render :xml=>@audio_timeline.to_xml()
  end

  def clear_timeline
    @audio_timeline = AudioTimeline.find(params[:id])

    @audio_timeline.audio_timeline_assets.each() {|timeline_asset|
      timeline_asset.destroy()
      #asset.audio_timeline_id = null
      #asset.save!
    }

    @audio_timeline = AudioTimeline.find(@audio_timeline.id)

    #render_timeline @audio_timeline
    render :xml=>@audio_timeline.to_xml()
  end

  def commit_timeline
    @audio_timeline = AudioTimeline.find(params[:id])
    @audio_timeline.status = AudioAsset::STATUS_READY
    @audio_timeline.save!

    render :xml=>@audio_timeline.to_xml()
  end


end




