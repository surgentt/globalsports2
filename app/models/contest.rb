require 'vendor/plugins/community_engine/app/models/contest'

class Contest < ActiveRecord::Base
  belongs_to :league

  def tag_id
    Tag.find(:first, :conditions=>{:name=>self.tag_name}).id rescue 0
  end

  def associated_users
    all = {}
    league.teams.each() { |team|
      users = team.users
      all[team.id]= users
    }
    all
  end

  def unregistered_roster_entries
    all = {}
    league.teams.each() { |team|
      roster_entries = team.team_sports.find(:first, :conditions=>{:name=>sport}).roster().delete_if { |re| re.user_id } rescue []
      all[team.id]= roster_entries
    }
    all
  end

  def inactive_users
    all = {}
    active_users = VideoClip.for_contest(self).collect(&:user)
    league.teams.each() { |team|
      users = team.team_sports.find(:first, :conditions=>{:name=>sport}).roster().delete_if { |re| re.user.nil? }.collect(&:user) - active_users rescue []
      all[team.id]= users
    }
    all
  end


end