class BaseController < ApplicationController
  include Viewable

  include Facebooker2::Rails::Controller

  before_filter :set_controller_vars
  before_filter :vidavee_login

  before_filter :fb_user_check
  before_filter :set_p3p_header_for_third_party_cookies

  before_filter :gs_login_required, :except => [:site_index, :chsfl_landing, :baberuth, :littleleague, :beta]
  #before_filter :billing_required, :except => [:site_index, :beta]
  before_filter :quickfind_setup
  before_filter :detect_promo

  before_filter :detect_ysl


  # Show the lockout page
  def beta
    render :layout => false
  end
  
  def site_index
    # What does a logged in user see first?
    if(logged_in?)    
      redirect_to(admin_dashboard_path) and return  if (current_user.admin?)
      redirect_to('/gamex/download') and return     if (current_user.gamex?)
      #redirect_to(dashboard_user_path(current_user)) and return
    end

    prepare_site_index_content

    #redirect_to '/baberuth'
    render :action => 'chsfl_landing'

  end

  def chsfl_landing
    prepare_site_index_content
  end

  def baberuth
  end

  def littleleague
    #@videos = [VideoAsset.find(4573)]
    #@game_dockey_string = @videos.collect(&:dockey).join(",")
    @series_video = SeriesVideo.find(1) rescue SeriesVideo.new
    @site_logo = '/images/partners/ysl.png';
  end

  def detect_ysl
    if request.url =~ /youthsportslive/
      if request.request_uri == '/'
        redirect_to "#{APP_URL}/littleleague"
      else
        redirect_to "#{APP_URL}#{request.request_uri}"
      end
      @site_name = 'Youth Sports Live';
      @site_logo = '/images/partners/ysl.png';
    else
      @site_name = 'Global Sports';
      @site_logo = '/images/gs_logo_small.png';
    end
  end


  # Turn off CE action caching, we are going to use Rails.cache
  def cache_action?
    false
  end
  

  def find_staff_scope(permission)

#    if current_user.admin?
#      @scopes = Permission.has_role(permission).collect(&:scope).uniq.sort_by(){ |s| "#{s.class} #{s.name}"}
#    else
#      @scopes = current_user.scopes_for(permission)
#    end

    @scopes = current_user.scopes_for(permission)

    if @scopes.empty?
      access_denied and return
    end

    scope = Permission.selector_string_to_scope(params[:scope_select])

    if scope && current_user.can?(permission, scope)
      @scope = scope
    elsif @scopes.size == 1
      @scope = @scopes[0]
    end

  end
  
  protected
 
  # shared by the shared_access_controller for preparing the index page 
  def prepare_site_index_content
    @athletes_of_the_week =
      Rails.cache.fetch('athletes_of_the_week', :expires_in => 30.minutes) do
      AthleteOfTheWeek.for_home_page
    end
    @articles_of_the_week =
      Rails.cache.fetch('articles_of_the_week', :expires_in => 30.minutes) do
      Post.highlighted_articles(@athletes_of_the_week.collect(&:id))
    end
    @games_of_the_week = games_of_the_week()
    @game_dockey_string = @games_of_the_week.collect(&:dockey).join(",")
  end

  def games_of_the_week
    games = Rails.cache.fetch('games_of_the_week', :expires_in => 30.minutes) do
      GameOfTheWeek.for_home_page || []
    end
    games
  end

  # This is a wrapper around the CE base_controllers login_required
  # which is commonly used as a before_filter. Really it comes from
  # CE/lib/authenticated_system. But many of the CE controllers use
  # it like
  #   before_filter :login_required, :except => [:foo]
  # or 
  #   before_filter :login_required, :only => [:foo]
  # 
  # Results vary dramatically in trying to add additional methods
  # that CE felt did not need to be protected, but which we
  # do want to protect. There is no (not yet) :exclude or :include
  # method on before_filter so in some cases it is just ignored.
  # Our solution to this it to just add the required hook as another
  # name so that we can require it where we need it with a very
  # simple syntax. The call is fast, not reuiring a DB
  # lookup, so that should not present too much of a problem
  #
  # The system is totally authenticated now except for actions
  # which have skip_before_filter for this filter.
  # It is easy to audit that all controllers extend from this
  # one and that only those actions which explicity skip this filter
  # should be viewable to the public side.


  # deprication, gs_login_required basically means that memebership is required

  def fb_user_check
    if current_facebook_user
      @facebook_user = FacebookUser.fromCookies(cookies)
      if @facebook_user && @facebook_user.user
        @current_user = @facebook_user.user
      end
    end
  end

  def gs_login_required

    #login_required
    #logged_in? && self.current_user.enabled? ? true : access_denied
    gs_membership_required
  end

  def member?
    logged_in? && self.current_user.enabled?
  end
  
  # use one of these more explicit filters instead

  def gs_membership_required
    member? ? true : access_denied
  end

  def gs_user_required
    logged_in? ? true : access_denied
  end

  ###



  def xgs_login_required
    #login_required
    #logged_in? && authorized? ? true : access_denied
    access = access_denied
    if logged_in?
      if self.current_user.role
        access = true
      end
    end
    access
  end
  
  # Ensure the status of the users billing
  def billing_required
    # Need to check that when they edit billing, we go ahead
    # and charge them at that time.

    #ppv user
    #return false if !current_user || !current_user.enabled?

    if current_user.nil?
      return true
    elsif !current_user.enabled?
      return false
    end
   
    if current_user.billing_needed? || current_user.credit_card_expired?
      flash[:error] = "Your billing information must be updated!"
      redirect_to(url_for(:controller => 'users', :action => 'edit_billing')) and return false
    end
    
    membership_required
  end

  # Ensure the status of the users membership,Your account is inactive. You must provide billing informationYour account is inactive. You must provide billing information accounts for promotional period expirations
  def membership_required
    return true if current_user.nil?

    membership = current_user.current_membership
    return true if membership.nil?

    if membership.expired?
      flash[:error] = "Your membership has expired. Please renew your account."
      redirect_to(url_for(:controller => 'users', :action => 'account_expired')) and return false
    elsif membership.canceled?
      flash[:error] = "Your membership has been canceled. Please renew your account."
      redirect_to(url_for(:controller => 'users', :action => 'membership_canceled')) and return false
    end
    
    return true
  end


  # Everyone visiting the site needs a vidavee login, even
  # unauthenticate users, so that they can see videos with a
  # valid vidavee sessionid and dockey.
  def vidavee_login

    begin
      @vidavee = Rails.cache.fetch('vidavee') { Vidavee.first }
    rescue
      logger.debug "Vidavee in cache is bad, replacing"
      Rails.cache.delete('vidavee')
      @vidavee = Rails.cache.fetch('vidavee') { Vidavee.first }
    end
    
    if (session[:vidavee].nil? || 
        session[:vidavee_expires].nil? || session[:vidavee_expires] < Time.now)
      logger.debug "Logging into vidavee again"
      session[:vidavee] = @vidavee.login()
      session[:vidavee_expires] = 5.minutes.from_now
    end
    @vidavee
  end

  # Set up information we need to drive the quickfind dropdowns
  # mostly memcached when running with memcached turned on
  def quickfind_setup
    #@quickfind_seasons = Rails.cache.fetch('quickfind_seasons') { VideoAsset.seasons }
    @quickfind_seasons = VideoAsset.seasons_cache
    @quickfind_schools = Rails.cache.fetch('quickfind_schools') { Team.having_videos.find(:all, :order => "name ASC") }
    @quickfind_states = Rails.cache.fetch('quickfind_states') { Team.states }
    @quickfind_counties = Rails.cache.fetch('quickfind_counties') { Team.counties }
    @quickfind_sports = Rails.cache.fetch('quickfind_sports') { VideoAsset.sports }
    @quickfind_cities = Rails.cache.fetch('quickfind_cities') { Team.cities }
  end
  
  # store promo codes from affiliates
  # and roster invitations
  def detect_promo
    if params[:promocode]
      @promocode = params[:promocode]
      cookies[:promocode] = { :value => @promocode, :expires => 30.days.from_now }
      if params[:promoteam]
        @promoteam = params[:promoteam]
        cookies[:promoteam] = { :value => @promoteam, :expires => 30.days.from_now } 
      end
    end
    if params[:roster_invite_key]
      @roster_invite_key = params[:roster_invite_key]
      cookies[:roster_invite_key] = { :value => @roster_invite_key, :expires => 30.days.from_now }
    end
  end

  def set_controller_vars
    @current_action = action_name
    @current_controller = controller_name
  end








end
