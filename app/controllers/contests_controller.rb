class ContestsController < BaseController

  skip_before_filter :verify_authenticity_token, :only => [:team_detail]

  before_filter :admin_required, :except => [:show, :team_detail ]

  skip_before_filter :gs_login_required, :only => [:show, :team_detail]
  
  def show
    @contest = Contest.find(params[:id])

    clips = VideoClip.find_tagged_with(@contest.tag_name).delete_if(){ |v| v.user.league_id != @contest.league_id }
    reels = VideoReel.find_tagged_with(@contest.tag_name).delete_if(){ |v| v.user.league_id != @contest.league_id }
    all = clips + reels

    @recent = all.sort() { |a,b| b.created_at <=> a.created_at }[0,3]
    @top = all.sort() { |a,b| b.favorites.size <=> a.favorites.size }[0,3]

    @teams = @contest.league.teams.sort() { |a,b| b.name <=> a.name }
    
  end

  def team_detail
    @contest = Contest.find(params[:id])
    @team = Team.find(params[:team_id])

    clips = VideoClip.find_tagged_with(@contest.tag_name).delete_if(){ |v| v.user.team_id != @team.id }
    reels = VideoReel.find_tagged_with(@contest.tag_name).delete_if(){ |v| v.user.team_id != @team.id }
    @all = clips + reels

    render :partial => 'team_detail'
  end

  def admin
    @contest = params[:id] ? Contest.find(params[:id]) :Contest.first

    @teams = @contest.league.teams.sort() { |a,b| b.name <=> a.name }

    @associated_users = @contest.associated_users
    @unregistered_roster_entries = @contest.unregistered_roster_entries
    @inactive_users = @contest.inactive_users
  end


end