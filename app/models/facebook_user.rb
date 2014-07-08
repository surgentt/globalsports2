require 'open-uri'



class FacebookUser

  # from filter call FacebookUser.fromCookies(cookies)

  CookieID = "fbs_#{Facebooker2.app_id}"

  def self.fromCookies(cookies)
    fb_user = nil

    if fbc = cookies[CookieID]
      cookie = fbc.sub(/^"/,'').sub(/"$/, '')
      fb_user = self.new(:cookie=>cookie)
    end

    fb_user
  end


  attr :user
  attr :uid

  def initialize(opts)

    opts[:cookie].split('&').each() { |kv|
      (k,v)=kv.split('=')
      RAILS_DEFAULT_LOGGER.info("  FB  #{k} => #{v}")
      instance_variable_set("@#{k}", v)
    }

    RAILS_DEFAULT_LOGGER.info("  FB  uid: #{@uid.inspect}")

    begin
      @user = user_by_uid() || user_by_email() || new_user() if @uid
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.info("  FB  failed to init user - #{e.message}")

      e.backtrace.each(){|l|
        RAILS_DEFAULT_LOGGER.info("  FB      #{l}")
      }
    end

  end

  def user_by_uid()
    RAILS_DEFAULT_LOGGER.info("  FB  find by uid")
    @user = User.find(:first, :conditions=>{:fb_uid=>@uid}) if @uid

    if @user
      @user.fb_access_token= @access_token
      @user.save
    end

    @user
  end

  def user_by_email()
    RAILS_DEFAULT_LOGGER.info("  FB  find by email")
    me = get_me()
    email = me['email']
    @user = User.find(:first, :conditions=>{:email=>email}) if email

    if @user
      @user.fb_uid = @uid
      @user.fb_access_token = @access_token
      @user.save
    end

    @user
  end

  def new_user()
    RAILS_DEFAULT_LOGGER.info("  FB  create user")
    me = get_me()
    @user = User.new

    @user.fb_uid = @uid
    @user.fb_access_token = @access_token

    @user.firstname = me['first_name']
    @user.lastname = me['last_name']
    @user.email = me['email']
    @user.birthday = me['birthday']
    @user.gender = me['gender'][0,1].upcase    rescue nil


    @user.team_id = 1
    @user.league_id = 1
    @user.login= "fb#{Time.now.to_i}-#{rand(1000)}"
    @user.password= Digest::SHA1.hexdigest(@user.login)[0,9]
    @user.password_confirmation = @user.password

    @user.role = Role[:member]
    @user.activated_at = Time.now
    @user.enable()

    @user.save

    @user.errors.each(){ |f,e|
      RAILS_DEFAULT_LOGGER.info "  FB  #{f}: #{e}"
    }

  end


  def get_me()
    if !@me
      me_url = "https://graph.facebook.com/me?access_token="+CGI.escape(@access_token)
      RAILS_DEFAULT_LOGGER.info("  FB  #{me_url}")
      j = open(me_url, 'User-Agent'=>::USER_AGENT).read
      RAILS_DEFAULT_LOGGER.info " FB me: "+j
      @me = JSON.parse(j)
    end
    @me
  end



  def self.xfromCookies(cookies)
    fb_user = nil

    if fbc = cookies["fbs_#{Facebooker2.app_id}"].sub(/^"/,'').sub(/"$/, '')
      fb_user = self.new()

      fbc.split('&').each() { |kv|
        (k,v)=kv.split('=')
        RAILS_DEFAULT_LOGGER.info("FACEBOOK VAR #{kv}")
        RAILS_DEFAULT_LOGGER.info("             #{k} => #{v}")
        fb_user.instance_variable_set("@#{k}", v)
        #logger.warn("facebook parameter assignment error #{kv}")
      }

    end

    fb_user
  end




end

#
#/me
#
#{
#   "id": "552498900",
#   "name": "Aaron Barnett",
#   "first_name": "Aaron",
#   "last_name": "Barnett",
#   "link": "http://www.facebook.com/aaronbarnett",
#   "username": "aaronbarnett",
#   "birthday": "03/26/1970",
#   "bio": "Time traveler, moving mainly forward at regular speed.",
#   "work": [
#      {
#         "employer": {
#            "id": "104183856326038",
#            "name": "Outerbody Media"
#         }
#      }
#   ],
#   "gender": "male",
#   "relationship_status": "In a relationship",
#   "significant_other": {
#      "name": "Kathy Stevens Barnett",
#      "id": "1039149902"
#   },
#   "religion": "Cognitarian",
#   "political": "Other",
#   "email": "aaron\u0040outerbody.com",
#   "timezone": -4,
#   "locale": "en_US",
#   "verified": true,
#   "updated_time": "2011-06-06T15:16:25+0000"
#}
#