


  // Team Sports

  gs.team_sports = {}

  gs.team_sports.current_open_panel = null;
  gs.team_sports.current_open_panel_id = null;

  gs.team_sports.panel_info = function(id) {
    panel_name = 'team-sport-'+id
    sport_div = $(panel_name)
    roster_div = sport_div.select('.roster')[0]

    map = {
      panel_name: panel_name,
      sport_div: sport_div,
      roster_div: roster_div
    }
    
    return map
  }

  gs.team_sports.sport_div_for = function(id) {
    return 'team-sport-'+id
  }

  gs.team_sports.open_panel = function(id) {
    map = this.panel_info(id)

    if(this.current_open_panel){
      this.current_open_panel.select('.opener')[0].select('a')[0].removeClassName('open')
      current_roster =  this.current_open_panel.select('.roster')[0]
      current_roster.hide();
    }
    if(this.current_open_panel_id != id){
      map.sport_div.select('.opener')[0].select('a')[0].addClassName('open')
      
      this.current_open_panel = map.sport_div
      this.current_open_panel_id = id

      this.load_current()

      map.roster_div.show()
    }else{
      //just closing
      gs.team_sports.current_open_panel = null;
      gs.team_sports.current_open_panel_id = null;
    }

  }

  gs.team_sports.load_current = function(){
    id = this.current_open_panel_id
    map = this.panel_info(id)
    map.roster_div.update('Loading roster...')
    new Ajax.Updater(map.roster_div, '/roster_entries/roster', {
        parameters: { "id": id },
        evalScripts: true
      });
  }

  gs.team_sports.sort_row = function(url) {
    id = gs.team_sports.current_open_panel_id
    map = this.panel_info(id)

    //map.roster_div.update('Loading roster...')

    new Ajax.Updater(map.roster_div, url, {
        parameters: { "id": id },
        evalScripts: true
      });
  }

  gs.team_sports.edit_row = function(ts_id, re_id) {
    map = this.panel_info(ts_id)
    url = '/roster_entries/roster'

    new Ajax.Updater(map.roster_div, url, {
        parameters: { "id": ts_id, "edit":re_id },
        evalScripts: true
      });
  }

  gs.team_sports.add_parent = function(ts_id, re_id) {
    map = this.panel_info(ts_id)
    url = '/roster_entries/roster'

    new Ajax.Updater(map.roster_div, url, {
        parameters: { "id": ts_id, "add_parent":re_id },
        evalScripts: true
      });
  }

  gs.team_sports.edit_parent = function(ts_id, p_id) {
    map = this.panel_info(ts_id)
    url = '/roster_entries/roster'

    new Ajax.Updater(map.roster_div, url, {
        parameters: { "id": ts_id, "edit_parent":p_id },
        evalScripts: true
      });
  }

  gs.team_sports.show_videos = function(id) {
    new dijit.Dialog({
        title: "Restricted Videos",
        style: "width: 400px",
        href:'/team_sports/videos/'+id
    }).show()
  }


  gs.team_sports.match_user = function(id) {
    new dijit.Dialog({
        id: 'dialog_match_user',
        title: "Possible Athlete Match",
        style: "width: 400px",
        href:'/roster_entries/match/'+id
    }).show()
  }

  gs.team_sports.button_off = function(label) {
      button = $('roster_entry_submit')
      button.value= label
      button.disabled = true;
      return true;
  }

  gs.team_sports.help = function(name) {
    url = "/team_sports/help?section="+name;
    args = "width=700, height=600, scrollbars=no";
    w = window.open(url, 'team_sports-help', args);
    w.focus();
  }

  gs.team_sports.resend = function(id) {
      url = '/team_sports/resend/'+id
      panel = 'team_sports_resend_'+id

      new Ajax.Request(url, {asynchronous:true, method:'get'});

      $(panel).fade()
  }