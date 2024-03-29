class ReportsController < BaseController

  skip_before_filter :gs_login_required, :only => [:detail]
  skip_before_filter :verify_authenticity_token, :only => [:clips, :player, :clip_detail, :sync, :update ]

  before_filter :except => [:show] do  |c| c.find_staff_scope(Permission::REPORT) end


  sortable_attributes 'reports.id', 'reports.name'

  def index
    
    if @scope
      @reports = Report.for_owner(@scope).paginate(:all, :order => sort_order, :page=>params[:page])
    end

  end

  def new
    @report = Report.new

  end

  def pop_new
    @report = Report.new

    render :update do |page|
      page.replace_html 'dialog', :partial => 'pop_new'
    end

  end

  def create
    @report = Report.new(params[:report])

    @report.owner = @scope
    @report.author = current_user

    if @report.save
      redirect_to build_reports_path(:id => @report.id)
    else
      render :action => "new"
    end
  end

  def edit
    @report = Report.find(params[:id])
  end

  def build
    @browser_reject = request.user_agent =~ /msie 6/i


    @report = Report.find(params[:id])
    @details = @report.details() #ReportDetail.for_report(@report)
    #@detail = @details.first

    @library = []
    @tree_detail = []

    @tree_detail += make_scope_video_tree()

    @tree_detail += make_gamex_tree_root()

  end


  def make_scope_video_tree()
    sport_list = []

    scope_vids = nil

    case @scope
    when Team
      scope_vids = VideoAsset.for_team(@scope)
    when League
      scope_vids = VideoAsset.for_league(@scope)
    end

    if(scope_vids)
      sports = {}

      scope_vids.each() { |video|
        sport_name = ( video.sport && !video.sport.empty?) ? video.sport : 'Unknown'

        seasons = sports[sport_name]
        if !seasons
          seasons = {}
          sports[sport_name] = seasons
        end

        season_name = ( video.game_date && video.game_date.year ) ? video.game_date.year : 'Unknown'

        season = seasons[season_name]
        if !season
          season = []
          seasons[season_name] = season
        end

        item = {}
        item[:id] = video.id
        item[:txt] = video.title
        item[:onclick] = 'gs_reports_loadclips'

        tag_items = []
        tags = Tag.find(:all, :joins=>"JOIN taggings on tag_id = tags.id JOIN video_clips on taggable_id = video_clips.id and taggable_type = 'VideoClip'", :conditions=>{ 'video_clips.video_asset_id'=>video.id} ).uniq
        tags.each() do |tag|
          tag_items << {
            :id => "#{video.id}-#{tag.id}",
            :txt => tag.name,
            :onclick => "gs_reports_loadclips"
          }
        end
        item[:items] = tag_items

        season << item

      }

      sports.each_pair() do |sport, seasons|
        season_list = []

        seasons.each_pair() do |season, items|
          season_branch = {
            :id=>"season-#{season}",
            :txt => season,
            :items => items,
            :onclick => "gs_reports_expandme"
          }
          season_list << season_branch
        end
        season_list.sort!() {|a,b| a[:txt].to_i <=> b[:txt].to_i }
        sport_tree_root = {
          :id=>"sport-#{sport}",
          :txt => sport,
          :items => season_list,
          :onclick => "gs_reports_expandme"
        }
        sport_list << sport_tree_root
      end
      sport_list.sort!() {|a,b| a[:txt] <=> b[:txt]}

    end

    sport_list
  end

  def make_gamex_tree_root()
    gamex_list = []

    GamexUser.for_user(current_user).each() do |gamex|

      # Gamex Videos

	    vids = VideoAsset.find(:all,
        :conditions => {
          :gamex_league_id => gamex.league.id,
          :video_status => 'ready'
        },
        :order => "created_at DESC"
      )

      items = []
      vids.each() { |video|
        item = {}
        item[:id] = video.id
        item[:txt] = video.title
        item[:onclick] = 'gs_reports_loadclips'
        items << item
      }
      gamex_tree_root = {
        :id=>"gamex #{gamex.league.id}",
        :txt => gamex.league.name,
        :items => items,
        :onclick => "gs_reports_expandme"
      }

      #@tree_detail
      gamex_list << gamex_tree_root

    end

    gamex_list
  end


  def sync
    @report = Report.find(params[:id])
    @small_player= params[:small_player]
    
    #@video_list = JSON.parse(params[:video_list].tr('\\', ''))
    list_param = params[:video_list].tr('\\', '').sub(/^"/,'').sub(/"$/,'')
    @video_list = JSON.parse(list_param)

    @report_details = []
    order = 1

    @video_list.each() do |video|
      if detail = ReportDetail.new(video)
        detail.report_id = @report.id
        detail.orderby = order += 1
        @report_details << detail
      end
    end

    Report.transaction {
      @report.details.each do |detail|
        detail.destroy
      end

      @report_details.each do |detail|
        detail.save
        #skipping errors
      end
    }

    dockeys = @report_details.collect(&:video).delete_if(){|v|v==nil}.collect(&:dockey)

    #vidavee = Vidavee.first
    #session_token = vidavee.login
    if dockey = @vidavee.new_playlist(session[:vidavee], "REPORT-PLAYLIST-#{@report.id}", dockeys, @report.dockey)
      @report.dockey = dockey
      @report.save
    end

    if params[:publish]
      render :partial => 'publish'
    else
      @detail = nil
      render :partial => 'player'
    end
  end


  def update
    @report = Report.find(params[:id])

    status = @report.update_attributes(params[:report])

    if status
      redirect_to reports_path(:scope_select=>@scope)
    else
      render :action => "edit"
    end

  end

  def clips
    @video_asset = VideoAsset.find(params[:video_asset_id])
    
    if params[:tag_id]
      @tag = Tag.find(params[:tag_id])
      @video_clips = VideoClip.find(:all, :conditions=>{ 'taggings.tag_id' => @tag.id, :video_asset_id=>@video_asset.id }, :joins=>"JOIN taggings on taggable_id = video_clips.id and taggable_type = 'VideoClip'")
    else
      @video_clips = VideoClip.find(:all, :conditions=>{:video_asset_id => @video_asset.id})
    end
    @video_clips.delete_if() { |v|
      !current_user.has_access?(v)
    }

    render :partial => 'clips'
  end



  def player
    @report = Report.find(params[:id])
    @small_player= params[:small_player]

    if params[:video_type]
      @detail = ReportDetail.new({:video_type=>params[:video_type],:video_id=>params[:video_id]}) #.for_report(@report).for_item_type(params[:video_type], params[:video_id])
      #@detail.report = @report
      @detail.find_video()
    end    

    render :partial => 'player'
  end



  def clip_detail
    @report = Report.find(params[:id])
    
    if params[:video_type]
      @detail = ReportDetail.new({:video_type=>params[:video_type],:video_id=>params[:video_id]}) #.for_report(@report).for_item_type(params[:video_type], params[:video_id])
      #@detail.report = @report
      @detail.find_video()
    end

    render :partial => 'clip_detail'
  end


  def detail
    debugger
    #@detail = ReportDetail.find(params[:id])
    @report = Report.find(params[:id])
    @detail = ReportDetail.new({:video_type=>params[:video_type],:video_id=>params[:video_id]})
    @detail.report = @report
    @small_player= params[:small_player]
    
    if @small_player
      player_width = 334
      player_height = 246
      frame_width = 334
      frame_height = 272
    else
      player_width = 480 #400
      player_height = 360 #295
      frame_width = 480 #400
      frame_height = 396 #331
    end

    @dockey = @detail.video_id ? @detail.video.dockey : @report.dockey
    @dockey ||= 0

    options = {}
    options[:indent] ||= 2

    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])

    xml.instruct! unless options[:skip_instruct]
    out = xml.vars {
      xml.frameW(frame_width)
      xml.frameH(frame_height)
      xml.playerW(player_width)
      xml.playerH(player_height)
      xml.thumbW(0)
      xml.thumbH(0)
      xml.numColumnsOrRows(0)
      xml.numPerColumnOrRow(0)
      xml.dockeys(@dockey)
      #xml.homepageLink("#{APP_URL}/#{team_path(channel.team_id)}") if channel.team_id
      xml.homepageLink(APP_URL)
      xml.validationUrl(APP_URL)

      xml.autoPlay(true)

      xml.position('bottom')
    }

    respond_to do |format|
      format.xml {
        render :xml=>out #@channel.to_flash_xml
      }
    end

  end


  def show
    @report = Report.find(params[:id])

    unless current_user.has_access?(@report) #AccessGroup.allow_access?(current_user, @report)
      access_denied
      return
    end

    @details = @report.details() #ReportDetail.for_report(@report)
    #@detail = @details.first
    

  end


end
