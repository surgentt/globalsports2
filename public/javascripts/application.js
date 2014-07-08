
//  if(!window.console){
//    window.console = {
//      log: function(m){},
//      warn: function(m, a){}
//    }
//  }

  // modeled after: # For rjs pages to tickle the flash on the current page
  function flashnow(msg) {
    $('flash_notice').select('span')[0].replace("<span>"+msg+"</span>")
    $('flash_notice').show()
  }

  function flasherror(msg) {
    $('flash_error').select('span')[0].replace("<span>"+msg+"</span>")
    $('flash_error').show()
  }

  var gs = {}

  gs.$N = function(tag, attrs, content){
    e = $(document.createElement(tag));
    if(attrs){
      for(attr in attrs)
        if( attrs.hasOwnProperty(attr) )
          e.setAttribute(attr, attrs[attr]);
    }
    if(content){
      e.update(content)
    }
    return e
  }


  gs.watch = function(tag, f) {
    var name = tag;
    var start = new Date().getTime();

    this.log = function(){
      var span = new Date().getTime() - start;
      console.log('JS_WATCH '+name+' in '+span)
      return span;""
    };

    if(f){
      f();
      this.log()
    }
  }


  gs.log = function(m) {
    if(window.console){
        console.log(m);
    }
  }

  gs.warn = function(m, a) {
    if(window.console){
        console.warn(m, a);
    }
  }

  gs.agent = function() {
      var out = []

      if(dojo.isIE)
        out.push('IE'+dojo.isIE)
      if(dojo.isMozilla)
        out.push('Mozilla '+dojo.isMozilla)
      if(dojo.isFF)
        out.push('FF'+dojo.isFF)
      if(dojo.isSafari)
        out.push('Safari '+dojo.isSafari)
      if(dojo.isOpera)
        out.push('Opera'+dojo.isOpera)
      if(dojo.isKhtml)
        out.push('K'+dojo.isKhtml)
      if(dojo.isAIR)
        out.push('AIR '+dojo.isAIR)
      if(dojo.isQuirks)
        out.push('Quirks '+dojo.isQuirks)
      //if(dojo.isBrowser)
      //  out.push('Browser '+dojo.isBrowser)
      if(dojo.isChrome)
        out.push('Chrome '+dojo.isChrome)
      if(dojo.isWebKit)
        out.push('WebKit '+dojo.isWebKit)


      return out.join(' ');

  }

  //

  gs.fb_login = function(){

    FB.api('/me', function(response) {
      console.log('you are '+response.name);
    });

    window.location.reload()
  }

  gs.fb_logout = function(){

  }

  gs.logout = function(){
    if(window.FB === undefined || FB.getSession === undefined ){
      window.location = "/logout"
    }else{
      if(FB.getSession() == undefined){
        window.location = "/logout"
      }else{
        FB.logout(function(response) {
          window.location = "/logout"
        });
      }
    }
  }

  //

  gs.register = function(){
    $('registrationForm')
  }

  //

  gs.ui = {}

  gs.ui.open_dialog = function(url, p_ajax_options) {

    ajax_options = $H({
      //parameters: { "id": id },
      evalScripts: true
    }).merge(p_ajax_options)


    dialog = $('dialog')


    popup = new Element("div")
    popup.addClassName('popup')

    popup = new Element("div")
    popup.addClassName('popup')

    closer = new Element("div")
    closer.addClassName('closer')

    close_button = new Element("a", { onclick:"Element.update('dialog', '');" })
    close_button.update('close[x]')
    closer.insert( close_button )

    popup.insert( closer )


    content = new Element("div", { id: 'dialog-content' })
    content.update( 'loading dialog content...' )

    popup.insert( content )


    dialog.update( popup )


    new Ajax.Updater(content, url, ajax_options);

  }




  //

  gs.events = {}

  gs.events.clip_created = function(dockey) {
    gs.log('gs.events.clip_created fired for '+dockey);
    gs.video_assets.clip_created(dockey)
  }





  // Team Management

  gs.team = {}

  gs.team.sport_list = [];

  gs.team.add_coach_panel_counter = 0;

  gs.team.add_coach = function(selected_sport) {

    counter_id = this.add_coach_panel_counter++
    panel_id = 'coach-panel-'+counter_id

    container = gs.$N('div', {'id': panel_id, 'class': 'team-coach-panel' })

    select = gs.$N('select', {
      'name': 'coach[sport-'+counter_id+']',
      'onchange': 'javascript:gs.team.pick_sport(this)'
    })

    selection_found = false

    len = gs.team.sport_list.size()
    for( s=0; s<len; s++) {
      sport = gs.team.sport_list[s]
      attrs = {}
      if(sport == selected_sport){
        selection_found = true
        attrs['selected'] = 1
      }
      select.appendChild( gs.$N('option', attrs, sport) )
    }

    select_other = selected_sport && !selection_found

    attrs = {'value':-1}
    if(select_other)
      attrs['selected'] = 1
    select.appendChild( gs.$N('option', attrs, 'Other') )

    container.appendChild(select);


    input = gs.$N('input', {
      'style': 'display: none',
      'type': 'text',
      'name': 'coach[sporttext-'+counter_id+']'
    })

    if(select_other)
      input.value = selected_sport

    container.appendChild(input);


    remove = gs.$N('a', {
      'href': "javascript:gs.team.remove_sport('"+panel_id+"')",
      'name': 'coach[sport-'+counter_id+']'
    })
    remove.update('X')
    container.appendChild(remove);


    $('coaching-roles').appendChild(container);

    this.pick_sport(select)

  }


  gs.team.pick_sport = function(target){
    target = $(target)
    console.log(target.value)
    if(target.value == -1){
      $(target).hide()
      input = $($(target).parentNode).select('input')[0]
      input.show()
    }
  }

  gs.team.remove_sport = function(target){
    target = $(target)
    console.log(target)
    target.remove()
  }




  // Groups

  gs.group = {}


  gs.group.get_user_selection_id = function(text, li) {
    $('access_user_user_id').value = li.id;
  }



  // Find My School

  gs.find_my_school = {}

  gs.find_my_school.update_state = function(state) {
    $('stateName').update(state);
    $('smallPrint').show();

    new Ajax.Updater('schoolList', '/teams/school_list', {
        parameters: { "state": state },
        evalScripts: true
    });
  }



gs.live = {}
gs.live.network_select = function() {
    select = $('camera_site_network_select')
    input = $('camera_site_network')

    if(select.value == 'Other'){
      //select.hide();
      input.show();
      input.value = ''
    }else{
      input.hide();
      input.value = select.value
    }
    autofill_video_title()
  }