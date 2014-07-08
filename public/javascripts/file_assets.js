

gs.file_assets = {

    file_name: null,
    block_count: null,

    form_submitted: false,

    retry_time: 3000

}


gs.file_assets.log = function (msg) {
    if(console)
        console.log("UPS  "+msg);
}



/* ****************************************************** */

gs.file_assets.mode = null;


gs.file_assets.getloader = function() {

    switch(gs.file_assets.mode ){
    case 'j':
        return document.gsups;
        break;
    case 'f':
        movieName = "gsupsf"
        return document[movieName] || window[movieName];
        break;
    default:
        throw 'No Uploader Selected';
    }

}

gs.file_assets.pick_uploader = function(c){
    var use_java = false;

    switch(c){
    case 'j':
        use_java = true;
        break;
    case 'f':
        use_java = false;
        break;
    default:
        use_java = navigator.javaEnabled();
        c = use_java ? 'j' : 'f'
    }

    if(use_java){
        $('ups-flash').hide()
        $('ups-java').show()
    }else{
        $('ups-java').hide()
        $('ups-flash').show()
    }

    this.mode = c
}


/* ****************************************************** */


// called from flash
gs.file_assets.ready_to_upload = function(name, block_count){
    gs.log('gs.file_assets.ready_to_upload('+name+','+block_count+')')

    this.file_name = name
    this.block_count = block_count
    
    this.enter_gate()

    if(this.form_submitted){
        this.start_push()
    }else{

    }
}

gs.file_assets.enter_gate = function(){
    $('ups-flash').select('.selector')[0].hide()
    $('ups-java').select('.selector')[0].hide()
}


gs.file_assets.get_progress_bar = function() {
    return $('ups-progress').select('.bar')[0]
}



gs.file_assets.note_progress = function(block, blockcount){
    var w = Math.floor(100 * block / blockcount);

    $('ups-progress').show();
    
    var bar = this.get_progress_bar(); //$('ups-progress').select('.bar')[0];

    bar.update(w+'%')
    bar.setStyle({width:w+'%'});

    //if(w > 50)
    //    bar.setStyle({width:w+'%', color:'white'});
    //else
    //    bar.setStyle({width:w+'%', color:'black'});

}

gs.file_assets.progress_animation = null;


gs.file_assets.start_progress_animation = function() {
    $('ups-progress').show();
  this.progress_animation = 0;
  this.animate_progress();
}

gs.file_assets.stop_progress_animation = function() {
  this.progress_animation = null;
}

gs.file_assets.animate_progress = function() {

    if(this.progress_animation != null){

        this.progress_animation = this.progress_animation + 1 % 35;
        
        var bar = this.get_progress_bar();

        var style = this.progress_animation+'px 0';
        bar.setStyle({backgroundPosition:style});

        var t = setTimeout('gs.file_assets.animate_progress()', 300);
    }
}



gs.file_assets.upload_button_name = 'upload-button'



/* ****************************************************** */

gs.file_assets.metadata_interupt = null

gs.file_assets.submit_form = function(callback){

    this.metadata_interupt = callback

    this.form_submitted = true

    var button = $(gs.file_assets.upload_button_name)

    button.disable()
    this.enter_gate()

    if(this.file_name != null){
        button.style.backgroundColor = 'green'
        button.value = 'Uploading...'
        this.start_push()
    }else{
        button.style.backgroundColor = 'yellow'
        button.value = 'Select a File to Upload'
    }
}

gs.file_assets.start_push = function(){
    gs.log('gs.file_assets.start_push()')
    //this.send({name:name,block_count:block_count})
    var button = $(gs.file_assets.upload_button_name)

    button.style.backgroundColor = 'green'
    button.value = 'Uploading...'

    if(this.metadata_interupt){
        this.metadata_interupt(this.push_file)
    }else{
        this.push_file()
    }
}

gs.file_assets.push_file = function(asset_type, asset_id, link){

    gs.file_assets.start_progress_animation();

    gs.log('gs.file_assets.push_file()')
    
    var a = $('new-file-asset-link')
    if(a)
        a.writeAttribute('href', link);

    switch(gs.file_assets.mode){
    case 'j':
        gs.log('.push_file(): use java')
        gs.file_assets.package({
            asset_type: asset_type, 
            asset_id: asset_id,
            name:gs.file_assets.file_name,
            block_count:gs.file_assets.block_count
        })
        break;
    case 'f':
        gs.log('.push_file(): use flex')
        gs.file_assets.getloader();
        var loader = gs.file_assets.getloader();
        loader.setTarget(asset_type, asset_id)
        loader.setAgent(gs.agent());
        loader.uploadFile();
        break;
    default:
        throw 'No Uploader Selected';
    }


}

gs.file_assets.upload_complete = function(filename){
    var button = $(gs.file_assets.upload_button_name)

    button.style.backgroundColor = 'white'
    button.style.color = 'GREEN'
    button.style.borderColor = 'GREEN'
    button.value = 'Upload Complete'

    var a = $('new-file-asset-link')
    if(a)
        a.update("Your video is here.")

    gs.file_assets.stop_progress_animation();
}


gs.file_assets.last_package = null;

gs.file_assets.package = function(info){
    gs.log('gs.file_assets.package()')
    gs.log(info)
    
    var block
    var params

    var watch = new gs.watch('send() > getBlock()', function(){
        block = gs.file_assets.getloader().getBlock()
    });

    if(info.id){
        params = {
            id: info.id,
            block_no: info.next_block,
            block: block
        }
    }else{
        params = {
            'asset_type': info.asset_type,
            'asset_id': info.asset_id,
            'name': info.name,
            'block_count': info.block_count,
            'block_no': 1,
            'block': block,
            'agent': 'J '+ gs.file_assets.getloader().version() + ' ' + gs.agent()
        };
    }

    this.last_package = params;

    this.send(params);
}

gs.file_assets.resend = function(){
    gs.log('gs.file_assets.resend()')
    this.send(this.last_package);
}

gs.file_assets.send = function(params){
    gs.log('gs.file_assets.send()')
    //gs.log(params)

    var url = '/file_assets/append'


    var watch = new gs.watch('send() > Ajax.Request()')

    if(true){

        //DOJO JS
        var deferred = dojo.xhrPost({
            url: url,
            content: params,
            handleAs: "json",
            load: function(info) {
                watch.log()
                //dojo.byId("response2").innerHTML = "Message posted.";

                gs.log('RESPONSE')
                //gs.log(info)

                //info = eval( '(' + transport.responseText + ')' )

                if(info.status = 'ok') {

                if(info.next_block > 0){
                    gs.file_assets.package(info)
                }else{
                    gs.file_assets.getloader().success(); //.allDone();
                    gs.file_assets.upload_complete();
                }

                }else{
                    flasherror(obj.err)
                }

            },
            error: function(error, ioArgs) {
                watch.log()
                gs.log('ERROR')
                gs.log(error)
                gs.log(ioArgs)

                //We'll 404 in the demo, but that's okay.  We don't have a 'postIt' service on the
                //docs server.
                //dojo.byId("response2").innerHTML = "Message posted.";
                //flasherror('Error Sending File, Retrying Packet');
                gs.file_assets.getloader().panic(); //.panicALittle();
                setTimeout("gs.file_assets.resend()",gs.file_assets.retry_time);
            }
        });

    }else{

        //PROTOTYPE JS
        var jax = new Ajax.Request(url, {
            method: 'post',
            parameters: params,
            onSuccess:  function (transport) {
            watch.log()

                gs.log(transport.responseText)

                info = eval( '(' + transport.responseText + ')' )

                if(info.status = 'ok') {

                if(info.next_block > 0){
                    gs.file_assets.package(info)
                }else{
                    gs.file_assets.getloader().success();
                }

                }else{
                flasherror(obj.err)
                }
            },
            onError: function(transport) {
                watch.log()
                //flasherror('Error Sending File, Retrying Packet');
                gs.file_assets.getloader().panic();
                setTimeout("gs.file_assets.resend()",gs.file_assets.retry_time);
            }
        })

    }

}





