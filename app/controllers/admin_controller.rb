class AdminController < BaseController

  before_filter :admin_required
  
  def dashboard
    logger.debug "In admin dashboard action"
  end

  def chsfl_email
    @all_users = User.all
    @chsfl_users = User.find_all_by_league_id(31)
    @since_sep = User.find(:all,:conditions => ['league_id = 31 and created_at > ?', '09/01/2011'.to_date])
  end

  def fb_count
    string = ''
    urls = []
    VideoReel.all.each do |v|
      if v.has_share_url? && (v.user.league_id == 31 || v.user.team.league_id == 31)
        urls << v.share_url
      end
    end
    string = urls.join('%22,%20%22')    
    @hp = Hpricot.XML(open("https://api.facebook.com/method/fql.query?query=select%20%20url,like_count,%20total_count,%20share_count,%20click_count%20from%20link_stat%20where%20url%20in(%22" + string + "%22)"))
  end

end
