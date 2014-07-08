ActionController::Routing::Routes.draw do |map|
  map.resources :v4_assets

  map.resources :gamex_users

  map.resources :promotions
  map.resources :sent_messages, :collection => {:admin_delete => :any, :delete_multi => :any}
  map.resources :members
  map.resources :pages
  map.resources :teams, :collection => { :find_my_school => :any, :school_list => :any }
  map.resources :leagues
  map.resources :gamex, :collection => { :download => :any, :admin => :any, :history => :any }
  map.resources :gamex_users
  map.resources :gamex_leagues
  map.resources :vidavees
  map.resources :video_assets, :new => { :save_video => :post, :swfupload => :post }, :collection => { :admin => :any, :download => :any, :upload_video => :any, :test => :any, :testup => :any }
  map.resources :video_clips, :collection => {:panel => :get}
  map.resources :video_reels
  map.resources :video_users, :new => { :save_video => :post, :swfupload => :post }, :collection => { :admin => :any }
  map.resources :messages, :collection => {:thread => :get, :new_text => :get}
  map.resources :billing
  map.resources :monikers
  map.resources :subscription_plans
  map.resources :membership
  map.resources :staffs, :collection => { :add => :any }
  map.resources :purchase_orders
  map.resources :ratings
  map.resources :shared_access  
  map.resources :channels, :collection => { :add => :any, :playerVars => :any }
  map.resources :access_groups, :collection => { :add_user => :any, :add_video => :any, :add_contact => :any, :pop_new_contact => :any, :pop_new_user => :any, :remove_user => :any, :remove_video => :any, :remove_contact => :any, :users => :any, :items => :any }
  map.resources :permissions
  map.resources :reports, :collection => { :pop_new => :any, :build => :any, :clips=>:any, :player=>:any, :clip_detail=>:any, :detail=>:any, :sync=>:any, :publish=>:any }
  map.resources :sessions, :collection => { :pop_login_box => :any }
  map.resources :team_sports, :collection => { :videos=>:any, :message=>:any, :help=>:get, :resend=>:get }
  map.resources :roster_entries, :collection => { :roster => :any, :post => :any, :match => :any, :update_entry=>:any, :submit_entry=>:any }
  map.resources :parents, :collection => { :post => :any }
  map.resources :audio_assets, :collection => { :get_next=>:any, :commit=>:any, :get_timeline=>:any, :add_to_timeline=>:any, :clear_timeline=>:any, :remove_from_timeline=>:any, :library=>:any }
  map.resources :file_assets, :collection => { :test => :any, :open => :any, :append => :any, :upload=>:any }

  map.resources :v4_assets
  map.resources :series, :collection => { :pull => :any }
  map.resources :series_videos, :collection => { :pull => :any, :stat => :any }

  map.resources :purchases, :collection => { :checkout => :post, :thanks => :get }
  map.buy_dvd 'purchases/buy/:code', :controller => 'purchases', :action => 'buy'


  map.resources :camera_sites, :collection => { :home => :any }

  map.live         'live',          :controller => 'camera_sites', :action => 'home'
  map.live_signup  'live/signup',   :controller => 'camera_sites', :action => 'new', :brand => 'BR'
  map.baberuth     'baberuth',   :controller => 'base', :action => 'baberuth'
  map.live_signup  'baberuth/signup',   :controller => 'camera_sites', :action => 'new', :brand => 'BR'

  map.chsfl_landing 'chsfl_landing',   :controller => 'base', :action => 'chsfl_landing'

  #map.baberuth     'littleleague',   :controller => 'base', :action => 'littleleague'
  #map.live_signup  'littleleague/signup',   :controller => 'camera_sites', :action => 'new', :brand => 'LL'

  map.facebook         'facebook',        :controller => 'users', :action => 'facebook'
  
  map.register         'register',        :controller => 'users', :action => 'register'
  map.forgot_password  'forgot_password', :controller => 'users', :action => 'forgot_password'
  map.user_logins      '/users/logins',   :controller => 'users', :action => 'logins'

  # Override CE on this one by getting mine in there first
  map.admin_dashboard  '/admin/dashboard', :controller => 'admin', :action => 'dashboard'
  map.admin_chsfl_email  '/admin/chsfl_email', :controller => 'admin', :action => 'chsfl_email'
  map.admin_fb_count  '/admin/fb_count', :controller => 'admin', :action => 'fb_count'

  map.signup '/signup/:inviter_id/:inviter_code', :controller => 'users', :action => 'signup'
  map.teamname '/teamname/:team_name', :controller => 'teams', :action => 'show_by_name'

  map.chsfl         'chsfl',        :controller => 'contests', :action => 'show', :id => 1

  # Turn on community engine routes
  map.from_plugin :community_engine

  # Add resources to the community engine routes
  map.resources :users, :member_path => '/:id', :nested_member_path => '/:user_id', :member => {
    :test => :any,
    :change_team_photo => :put,
    :change_league_photo => :put,
  } do |user|
    user.resources :messages
    user.resources :video_assets
    user.resources :video_clips
    user.resources :video_reels
    user.resources :video_users
    user.resources :photos, :collection => {:swfupload => :post, :slideshow => :get}
  end


  # Turn on the static pages with permalink routes
  map.info 'info/:permalink', :controller => 'pages', :action => 'show'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  # A catch all route
  if ENV['RAILS_ENV'] == 'production' || ENV['RAILS_ENV'] == 'qa'
    map.connect '*path', :controller => 'base', :action => 'site_index'
  end
  
end


