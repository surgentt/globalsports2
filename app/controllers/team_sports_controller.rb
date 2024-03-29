class TeamSportsController < BaseController

  before_filter :except => [:show] do  |c| c.find_staff_scope(Permission::COACH) end

  skip_before_filter :verify_authenticity_token, :only => [:roster, :videos, :library ]

  #sortable_attributes 'team_sports.name', 'team_sports.id', 'teams.name'


  def index
    conditions = {}
    
    if !current_user.admin?
      conditions = { :id => @scopes.collect(&:id) }
    end

    @team_sports = TeamSport.paginate(:all, :order => 'name asc', #sort_order,
      :conditions => conditions,
      :page => params[:page])

  end


  def show
    @team_sport = TeamSport.find(params[:id])
    load_team_and_related_videos(@team)
    load_team_favorites(@team)
    @header_post = Post.admin_team_headers.first

    respond_to do |format|
      format.html # show.haml
      format.xml  { render :xml => @team }
      format.js { render :xml => @team }
    end
  end


  def new
    @team_sport = TeamSport.new
  end


  def edit
    @team_sport = TeamSport.find(params[:id])

    unless current_user.can?(Permission::COACH, @team_sport)
      flash[:notice] = "You don't have permission to edit that record"
      access_denied and return
    end

    @leagues = League.all(:order => "name asc")
  end


  def create
    @team_sport = TeamSport.new(params[:team_sport])

    @avatar = Photo.new(params[:avatar])
    @avatar.user_id = current_user.id
    if @avatar.save
      @team_sport.avatar = @avatar
    else
      flash[:notice] = 'Avatar was not created.'
    end

    if @team_sport.save

      flash[:notice] = 'Sport was successfully created.'
      redirect_to team_sports_url
    else
      render :action => "new"
    end
  end


  def update
    @team_sport = TeamSport.find(params[:id])

    unless current_user.can?(Permission::COACH, @team_sport)
      flash[:notice] = "You don't have permission to edit that record"
      access_denied and return
    end

    @avatar = Photo.new(params[:avatar])
    @avatar.user_id = current_user.id
    if @avatar.save
      @team_sport.avatar = @avatar
    else
      flash[:notice] = 'Avatar was not created.'
    end

    if @team_sport.update_attributes(params[:team_sport])
      
      flash[:notice] = 'School info was successfully updated.'
      redirect_to team_sports_url
    else
      render :action => "edit"
    end
  end


  def destroy
    @team_sport = TeamSport.find(params[:id])

    unless current_user.can?(Permission::COACH, @team_sport)
      flash[:notice] = "You don't have permission to edit that record"
      access_denied and return
    end

    @team_sport.destroy

    redirect_to(team_sports_url)
  end

  def xroster
    @team_sport = TeamSport.find(params[:id])
    @roster_entry = RosterEntry.new()
    @roster_entry.access_group = @team_sport.access_group
    render :layout => false
  end

  def videos
    @team_sport = TeamSport.find(params[:id])
    @access_group = @team_sport.access_group
    
    #render :template=>'access_groups/items' , :layout => 'dialog'
    render :partial=>'videos'
  end


  def message
    @team_sport = TeamSport.find(params[:id])

    message_type = params[:message_type].to_i

    p = { }

    to = params[:recipient].to_i

    if (to & 1)>0
      p[:to_group]= "#{@team_sport.staff_access_group.id rescue -1}"
    end

    if (to & 2)>0
      if p[:to_group]
        p[:to_group]+=','
      else
        p[:to_group]=''
      end
      p[:to_group]+= "#{@team_sport.access_group.id}"
    end

    if (to & 4)>0
      #roster = RosterEntry.roster(@team_sport.access_group).find(:all)

      if message_type == 2
        p[:to_phones]= RosterEntry.roster(@team_sport.access_group).find(:all).collect(&:parents).flatten.collect(&:phone).join(',')
      else
        p[:to_emails]= RosterEntry.roster(@team_sport.access_group).find(:all).collect(&:parents).flatten.collect(&:email).join(',')
      end

    end

    action = case message_type
    when 2
      new_text_messages_path(p)
    else
      new_message_path(p)
    end

    redirect_to action

  end


  def message1
    @team_sport = TeamSport.find(params[:id])

    to = case params[:recipient].to_i
    when 1
      "#{@team_sport.staff_access_group.id rescue -1}"
    when 2
      "#{@team_sport.access_group.id}"
    when 3
      "#{@team_sport.access_group.id},#{@team_sport.staff_access_group.id rescue -1}"
    else
      ''
    end

    action = case params[:message_type].to_i
    when 1
      new_message_path(:to_group=>to)
    when 2
      new_text_messages_path(:to_group=>to)
    else
      new_message_path(:to_group=>to)
    end

    redirect_to action

  end


  def resend
    @team_sport = TeamSport.find(params[:id])

    unless current_user.can?(Permission::COACH, @team_sport)
      flash[:notice] = "You don't have permission to edit that record"
      access_denied and return
    end

    @team_sport.roster.each() do |re|
      UserNotifier.deliver_roster_invite({:to=>re, :from=>current_user}) if re.user == nil
    end

    render :text => 'OK'
  end

  def help
    render :action=>'help', :layout=>false
  end

end