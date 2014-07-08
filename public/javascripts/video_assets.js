
  gs.video_assets = {}

  gs.video_assets.base_model = 'video_asset'

  gs.video_assets.select_sport = function() {
    select = $(this.base_model+'_sport_select')
    input = $(this.base_model+'_sport')

    if(select.value == 'Other'){
      select.hide();
      input.show();
    }else{
      input.value = select.value
    }
    autofill_video_title()
  }

  gs.video_assets.select_game_level = function() {
    select = $(this.base_model+'_game_level_select')
    input = $(this.base_model+'_game_level')

    if(select.value == 'Other'){
      select.hide();
      input.show();
    }else{
      input.value = select.value
    }
    autofill_video_title()
  }

  gs.video_assets.select_game_type = function() {
    select = $(this.base_model+'_game_type_select')
    input = $(this.base_model+'_game_type')

    if(select.value == 'Other'){
      select.hide();
      input.show();
    }else{
      input.value = select.value
    }
    autofill_video_title()
  }



  //javascript:gs.video_assets.start_upload()

  gs.video_assets.send_meta = function() {
    $(this.base_model+'_submit').value = "Uploading...";
    $(this.base_model+'_submit').disabled = true;

    form = $('upload_form')
    url = '/'+this.base_model+'s/create'

    var jax = new Ajax.Request(url, {
      method: 'post',
      parameters: Form.serialize(form),
      onSuccess:  function (transport) {
          //uploader.swfu.settings.post_params['id'] = transport.responseText
          obj = eval( '(' + transport.responseText + ')' )

          if(obj.id > 0) {
            uploader.swfu.addPostParam('id', obj.id)
            gs.video_assets.start_upload()
          }else{
            flasherror(obj.err)
            $(gs.video_assets.base_model+'_submit').value = "Upload";
            $(gs.video_assets.base_model+'_submit').disabled = false;
          }
      },
      onError: function(transport) {
        flasherror('Could not save video');
        $(gs.video_assets.base_model+'_submit').value = "Upload";
        $(gs.video_assets.base_model+'_submit').disabled = false;
      }
    })
  }


  gs.video_assets.start_upload = function() {
    $(this.base_model+'_submit').value = "Uploading Video...";
    $(this.base_model+'_submit').disabled = true;
    uploader.swfu.startUpload();
  }

  gs.video_assets.video_loaded = function() {
    $(this.base_model+'_submit').value = "Upload Complete";
    var form = document.getElementById('submit_form');
    //form.submit();
    window.location='/'+this.base_model+'s/submit_video/'+uploader.swfu.settings.post_params['id']
  }

  gs.video_assets.video_failed = function(msg) {

    $(gs.video_assets.base_model+'_submit').value = "Try Again";
    $(gs.video_assets.base_model+'_submit').disabled = false;

//    var txtFileName = document.getElementById("uploaded_file_path");
//    txtFileName.value = "";

    //video_asset_submit.value = "Try Again";
    //video_asset_submit.disabled = false;

    //flasherror(msg);
  }

  gs.video_assets.ppv_dialog = null;

  gs.video_assets.buy_video = function(id) {
    this.ppv_dialog = new dijit.Dialog({
        title: "Pay-Per-View: Purchase Video",
        //style: "width: 600px",
        href:'/users/ppv_reg/'+id
    })
    this.ppv_dialog.show()
  }

  gs.video_assets.submit_ppv_purchase = function() {
    var params = $('ppvRegForm').serialize(true)

    $('ppvRegContent').update('<div style="height: 500px; width: 600px; overflow: auto;">submitting info...</div>')

    new Ajax.Updater('ppvRegContent', '/users/ppv_reg_create', {
      method:     'post',
      parameters: params,
      evalScripts: true
      //onFailure:  function() {Element.classNames('about-content').add('failure')},
      //onComplete: function() {new Effect.BlindDown('about-content', {duration: 0.25})}
    });

  }

  gs.video_assets.ppv_new_user = function(){
    $$('.new_user_only').each(function(e, i){e.show()})
  }
  gs.video_assets.ppv_existing_user = function(){
    $$('.new_user_only').each(function(e, i){e.hide()})
  }



gs.video_assets.submit_upload = function(form) {
    gs.log('gs.video_assets.submit_upload()')
   
    var title = $(gs.video_assets.base_model+'_title').value
    var filename = 1 //$(gs.video_assets.base_model+'_uploaded_file_path').value
    
    if(title == "" || filename == ""){
      html = '<div id="errorExplanation" class="errorExplanation">There were problems with the following fields:<ul>'
    
      if(title == ""){
        html += '<li>Title can\'t be blank</li>'
      }
      
      if(filename == ""){
        html += '<li>Please select a file to upload</li>'
      }

      html += '</ul></div>'

      $('uploadProgressContainer').innerHTML = html;
      return false;
    }

      $('uploadProgressContainer').innerHTML = '';

    //this.uploader.submit(form, {'onStart' : this.uploader.startCallback, 'onComplete' : this.uploader.completeCallback})

    if(gs.file_assets.mode == 'x' )
      gs.video_assets.submit_form()
    else
      gs.file_assets.submit_form( gs.video_assets.submit_form )

    return false;
}



gs.video_assets.submit_form = function(on_success) {
    gs.log('gs.video_assets.submit_form()')

    dojo.xhrPost({
        form: 'upload_form',
        handleAs: "json",
        handle: function(data,args){
          if(data.errors){
            gs.warn("Error in gs.video_assets.submit_form(): ", data.errors);
            var msg = ''
            data.errors.each(function(e){
                msg += e.attr+": "+e.msg+'<br>';
            });
            flasherror(msg);
          }else{
            gs.log('.submit_form(): success ')
            gs.log(data);
            on_success(data.asset_type, data.asset_id, data.link)
          }
        }
    });

}




gs.video_assets.xuploader = {

  /**
  *
  *  AJAX IFRAME METHOD (AIM)
  *  http://www.webtoolkit.info/
  *
  **/

	frame : function(c) {

		var n = 'f' + Math.floor(Math.random() * 99999);
		var d = document.createElement('DIV');
		d.innerHTML = '<iframe style="display:none" src="about:blank" id="'+n+'" name="'+n+'" onload="gs.video_assets.uploader.loaded(\''+n+'\')"></iframe>';
		document.body.appendChild(d);

		var i = document.getElementById(n);
		if (c && typeof(c.onComplete) == 'function') {
			i.onComplete = c.onComplete;
		}

		return n;
	},

	form : function(f, name) {
		f.setAttribute('target', name);
	},

	submit : function(f, c) {
		this.form(f, this.frame(c));
		if (c && typeof(c.onStart) == 'function') {
			return c.onStart();
		} else {
			return true;
		}
	},

	loaded : function(id) {
		var i = document.getElementById(id);
		if (i.contentDocument) {
			var d = i.contentDocument;
		} else if (i.contentWindow) {
			var d = i.contentWindow.document;
		} else {
			var d = window.frames[id].document;
		}
		if (d.location.href == "about:blank") {
			return;
		}

		if (typeof(i.onComplete) == 'function') {
			i.onComplete(d.body.innerHTML);
		}
	},

  startCallback: function() {
    // make something useful before submit (onStart)
    document.getElementById('uploadProgressContainer').innerHTML = '<br><table><tr><td valign=top><img src="/images/ajax-loader.gif" style="padding-right:16px;"></td><td valign=top>Your video is uploading. This may take several minutes to several hours depending on the size of your video, and the speed of your internet connection. For reference, a 500MB file on a home-internet connection will usually take about an hour to upload. Please note that this browser window must remain open until upload completes.</td></tr></table>';
    $(gs.video_assets.base_model+'_submit').value = "Uploading Video...";
    $(gs.video_assets.base_model+'_submit').disabled = true;
    return true;
  },

  completeCallback: function(response) {
    // make something useful after (onComplete)
    //document.getElementById('nr').innerHTML = parseInt(document.getElementById('nr').innerHTML) + 1;
    document.getElementById('uploadProgressContainer').innerHTML = response;
    $(gs.video_assets.base_model+'_submit').value = "Upload Complete";
  }



}




  // CLIPSUPPORT

  gs.video_assets.clips_created = 0

  // 2E672AA2544C64318E6A248844C1B2C1
  // gs.video_assets.clip_created('C696A3481E6BE16B6C44BF0121DD6F5F')
  gs.video_assets.clip_created = function(dockey){
    if(++gs.video_assets.clips_created > 1)
      $('promote_reels').show();

    iframe = {
      id: 'clipPanel-'+dockey,
      'class': 'clipPanel',
      src:'/video_clips/panel?dockey='+dockey,
      width: '200px',
      height: '200px',
      scrolling: 'no'
    }
    iframe_node = gs.$N('iframe', iframe)
    $('clipDropper').insert({ top: iframe_node })

  }










