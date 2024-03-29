module BaseHelper
  def page_title
    app_base = AppConfig.community_name
    tagline = " | #{AppConfig.community_tagline}"
    
    title = app_base
    case @controller.controller_name
    when 'base'
      case @controller.action_name
      when 'popular'
        title = 'Popular posts &raquo; ' + app_base + tagline
      else 
        title += tagline
      end
    when 'posts'
      if @post and @post.title
        title = @post.title + ' &raquo; ' + app_base + tagline
        title += (@post.tags.empty? ? '' : " &laquo; Keywords: " + @post.tags[0...4].join(', ') )
      end
    when 'users'
      if @user and @user.full_name
        title = @user.full_name
        title += ', expert in ' + @user.offerings.collect{|o| o.skill.name }.join(', ') if @user.vendor? and !@user.offerings.empty?
        title += ' &raquo; ' + app_base + tagline
      else
        title = 'Showing users &raquo; ' + app_base + tagline
      end
    when 'photos'
      if @user and @user.full_name
        title = @user.full_name + '\'s photos &raquo; ' + app_base + tagline
      end
    when 'video_assets'
      if @controller.action_name == 'show' and @video_asset
        title = @video_asset.title + ' &raquo; ' + app_base + tagline
      elsif @user and @user.full_name
        title = @user.full_name + '\'s videos &raquo; ' + app_base + tagline
      end
    when 'video_reels'
      if @controller.action_name == 'show' and @video_reel
        title = @video_reel.title + ' &raquo; ' + app_base + tagline
      elsif @user and @user.full_name
        title = @user.full_name + '\'s reels &raquo; ' + app_base + tagline
      end
    when 'video_clips'
      if @controller.action_name == 'show' and @video_clip
        title = @video_clip.title + ' &raquo; ' + app_base + tagline
      elsif @user and @user.full_name
        title = @user.full_name + '\'s clips &raquo; ' + app_base + tagline
      end
    when 'shared_access'
      if @shared_access and @shared_access.video? and @shared_access.item
        title = @shared_access.item.title + ' &raquo; ' + app_base + tagline
      end    
    when 'clippings'
      if @user and @user.full_name
        title = @user.full_name + '\'s clippings &raquo; ' + app_base + tagline
      end
    when 'tags'
      if @tag and @tag.name
        title = @tag.name + ' posts, photos, and bookmarks &raquo; ' + app_base + tagline
        title += ' | Related: ' + @related_tags.join(', ')
      else
        title = 'Showing tags &raquo; ' + app_base + tagline
      end
    when 'categories'
      if @category and @category.name
        title = @category.name + ' posts, photos and bookmarks &raquo; ' + app_base + tagline
      else
        title = 'Showing categories &raquo; ' + app_base + tagline            
      end
    when 'skills'
      if @skill and @skill.name
        title = 'Find an expert in ' + @skill.name + ' &raquo; ' + app_base + tagline
      else
        title = 'Find experts &raquo; ' + app_base + tagline            
      end
    when 'sessions'
      title = 'Login &raquo; ' + app_base + tagline
    when 'pages'
      if @page and @page.name
        title = @page.name + ' &raquo; ' + app_base + tagline
      end
    end

    if @page_title
      title = @page_title + ' &raquo; ' + app_base + tagline
    elsif title == app_base          
      title = ' Showing ' + @controller.controller_name + ' &raquo; ' + app_base + tagline
    end	
    title
  end
  
  def more_comments_links(commentable)
    html = link_to "&raquo; All comments", comments_url(commentable.class.to_s, commentable.to_param)
    #html += "<br />"
    #html += link_to "&raquo; Comments RSS", formatted_comments_url(commentable.class.to_s, commentable.to_param, :rss)
    html
  end
  
  def add_friend_button(user)
    html = "<span class='friend_request' id='friend_request_#{user.id}'>"
    html += link_to_remote "Request friendship!",
    {:update => "friend_request_#{user.id}",
      :loading => "$$('span#friend_request_#{user.id} span.spinner')[0].show(); $$('span#friend_request_#{user.id} a.add_friend_btn')[0].hide()", 
      :complete => visual_effect(:highlight, "friend_request_#{user.id}", :duration => 1),
      500 => "alert('Sorry, there was an error requesting friendship')",
      :url => hash_for_user_friendships_url(:user_id => current_user.id, :friend_id => user.id), 
      :method => :post },
    {:class => "add_friend genericButton"}
    html +=	"<span style='display:none;' class='spinner'>"
    html += image_tag 'spinner.gif', :plugin => "community_engine"
    html += "<a class='genericButton' name='#'>Requesting friendship...</a></span></span>"
    html
  end
  
  def cc_displayable_fill(credit_card)
    if credit_card.displayable_number
      "************#{credit_card.displayable_number}"
    else
      "****************"
    end
  end

  def count_words(text)
    Utilities::count_words(text)
  end

  def truncate_words(text, length = 30, end_string = '...')
    Utilities::truncate_words(text,length,end_string)
  end
  
  def protected_link_to name, url, options = {}
    if current_user
      link_to name, url, options
    else
      session[:return_to] = url
      options[:complete] = evaluate_remote_response
      link_to_remote name, {:url => {:controller=>:sessions, :action=>:pop_login_box}}, options
      #%Q~<a onclick="$('loginPopup').show()~
    end
  end

  def select_or_other()
    

  end

end
