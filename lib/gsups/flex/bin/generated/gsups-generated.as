
/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    
 *  Class:      gsups
 *  Source:     /Users/aaron/dev/gsports/lib/gsups/flex/src/gsups.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2011.04.08 15:32:13 EDT
 */

package 
{

import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.events.MouseEvent;
import flash.external.*;
import flash.geom.*;
import flash.media.*;
import flash.net.*;
import flash.printing.*;
import flash.profiler.*;
import flash.system.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.*;
import flash.xml.*;
import mx.binding.*;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.filters.*;
import mx.styles.*;
import spark.components.Application;
import spark.components.Button;
import spark.components.Label;


[SWF( height='100', width='600')]
[Frame(extraClass="_gsups_FlexInit")]

[Frame(factoryClass="_gsups_mx_managers_SystemManager")]


public class gsups
    extends spark.components.Application
{

    [Bindable]
	/**
 * @private
 **/
    public var consoleLabel : spark.components.Label;

    [Bindable]
	/**
 * @private
 **/
    public var selectButton : spark.components.Button;





    /**
     * @private
     **/
    public function gsups()
    {
        super();





        // layer initializers

       
        // properties
        this.minWidth = 600;
        this.minHeight = 100;
        this.width = 600;
        this.height = 100;
        this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_gsups_Array1_c);


        // events
        this.addEventListener("creationComplete", ___gsups_Application1_creationComplete);












    }

    /**
     * @private
     **/ 
    private var __moduleFactoryInitialized:Boolean = false;

    /**
     * @private
     * Override the module factory so we can defer setting style declarations
     * until a module factory is set. Without the correct module factory set
     * the style declaration will end up in the wrong style manager.
     **/ 
    override public function set moduleFactory(factory:IFlexModuleFactory):void
    {
        super.moduleFactory = factory;
        
        if (__moduleFactoryInitialized)
            return;

        __moduleFactoryInitialized = true;


        // our style settings


        // ambient styles
        mx_internal::_gsups_StylesInit();

                         
    }
 
    /**
     * @private
     **/
    override public function initialize():void
    {


        super.initialize();
    }



		private var version:String					= Version.string;
		private var agent:String					= 'F '+version;
		
		
		private var CALL_JS_LOG:String 				= "gs.file_assets.log";
		private var CALL_JS_FILE_READY:String 		= "gs.file_assets.ready_to_upload";
		private var CALL_JS_UPLOAD_COMPLETE:String 	= "gs.file_assets.upload_complete";
		private var CALL_JS_NOTE_PROGRESS:String	= "gs.file_assets.note_progress";
		
		private var FILE_UPLOAD_URL:String			= "/file_assets/upload";
			
		private var file:FileReference;
		//private const FILE_TYPES:Array 				= [new FileFilter("Video File","*.mp4;*.mpg;*.avi;*.wmv")];
		private const FILE_TYPES:Array 				= [new FileFilter("Video File","*.3g2;*.3gp;*.3gp2;*.3gpp;*.asf;*.avi;*.avs;*.dv;*.flc;*.fli;*.flv;*.gvi;*.m1v;*.m2v;*.m4e;*.m4u;*.m4v;*.mjp;*.mkv;*.moov;*.mov;*.movie;*.mp4;*.mpe;*.mpeg;*.mpg;*.mpv2;*.qt;*.rm;*.ts;*.vfw;*.vob;*.wm;*.wmv")];
		
		private var retries:int						= 3;
		
		private var asset_type:String;
		private var asset_id:int;
		
		// flex UI
		
		public function setup():void {
			this.log("setting up");
			
			//Watch.setConsole(this.log);
			
			////progressBar.mode = ProgressBarMode.MANUAL;
			
			ExternalInterface.addCallback("setTarget", this.setTarget);
			ExternalInterface.addCallback("setAgent", this.setAgent);
			ExternalInterface.addCallback("uploadFile", this.uploadFile);
			
			
			this.log("Version: "+this.version);
			
			//this.console("Version: "+this.version);
		}
		
		
		private function console(s:String):void
		{
			consoleLabel.text = s;
		}
		
		private function log(s:String):void
		{
			trace(s)
			ExternalInterface.call( CALL_JS_LOG, s );
		}
		
		
		////////////////////////////////////////////////////////////////////////
		// JS Exposed Methods
		////////////////////////////////////////////////////////////////////////
		
		
		
		private function setTarget(asset_type:String, asset_id:int):String
		{
			this.log('setTarget()');
			
			this.asset_type = asset_type;
			this.asset_id   = asset_id;
			
			return this.asset_type + '/' + this.asset_id;
		}
		
		private function setAgent(agent_str:String):void
		{
			this.log('setAgent()');

			this.agent = 'F '+ this.version + ' ' + agent_str;
		}
		
		
		////////////////////////////////////////////////////////////////////////
		// UI Driven Flow
		////////////////////////////////////////////////////////////////////////
		
		
		
		//private function selectFile(event:MouseEvent):void
		private function selectFile():void
		{			
			this.log('selectFile()');
			file = new FileReference();
			file.addEventListener(Event.SELECT, onFileSelect);
			file.addEventListener(Event.CANCEL, onCancel);
			file.browse(FILE_TYPES);
		}
		
		
		private function onCancel(e:Event):void
		{
			this.log('aww!');
			file = null;
		}
		
		
		private function onFileSelect(e:Event):void
		{
			this.log('onFileSelect()');
			
			selectButton.enabled = false;
			
			//progressBar.indeterminate = false; 
			//progressBar.visible = false; //true;
			
      this.console("Ready to uploaded "+file.name)

			//file = arrUploadFiles[arrUploadFileNames.indexOf(sFileNameToUpload)];
			
			file.addEventListener(ProgressEvent.PROGRESS, 	onUploadProgress);
			file.addEventListener(Event.COMPLETE, 			onUploadComplete);
			file.addEventListener(IOErrorEvent.IO_ERROR, 	onUploadError);
			
			//uploadFile();
			
			ExternalInterface.call( CALL_JS_FILE_READY, file.name, 1 );
		}
			
		private function uploadFile():void
		{
			var request:URLRequest  = new URLRequest(FILE_UPLOAD_URL);
			request.method = URLRequestMethod.POST;
			
			var params:URLVariables = new URLVariables();
			params.asset_type = this.asset_type;
			params.asset_id	  = this.asset_id;
			params.agent	  = this.agent;
			
			request.data = params;
			
			file.upload(request);
		}
		
		private function onUploadProgress(event:ProgressEvent):void {
			var pfile:FileReference = FileReference(event.target);
			
			this.log("progressHandler name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
			
			//var percent:int = (99 * event.bytesLoaded / event.bytesTotal);

			//this.console("Uploaded "+percent+"% of "+file.name)
			this.console("Uploading "+file.name)
			
			ExternalInterface.call( CALL_JS_NOTE_PROGRESS, event.bytesLoaded, event.bytesTotal );
			
			////theProgress.mode = ProgressBarMode.MANUAL;
			////progressBar.setProgress(event.bytesLoaded, event.bytesTotal)
			//progressBar.setProgress(percent, 100)
		}
		
		
		
		private function onUploadComplete(e:Event):void
		{
			this.log('onUploadComplete()');
			
			//progressBar.visible = false;
			this.console("Uploaded "+file.name)
			
			ExternalInterface.call( CALL_JS_UPLOAD_COMPLETE, file.name );
			
			//file = null;
		}
		
		private function onUploadError(e:IOErrorEvent):void
		{
			this.log("Error loading file : " + e.text);
			if(this.retries-- > 0){
				uploadFile();
			}
			
		}
		
		
		
		
		
		
		
		
		
	



    //	supporting function definitions for properties, events, styles, effects
private function _gsups_Array1_c() : Array
{
	var temp : Array = [_gsups_Button1_i(), _gsups_Label1_i()];
	mx.binding.BindingManager.executeBindings(this, "temp", temp);
	return temp;
}

private function _gsups_Button1_i() : spark.components.Button
{
	var temp : spark.components.Button = new spark.components.Button();
	temp.x = 20;
	temp.y = 20;
	temp.label = "Select Video";
	temp.addEventListener("click", __selectButton_click);
	temp.id = "selectButton";
	if (!temp.document) temp.document = this;
	selectButton = temp;
	mx.binding.BindingManager.executeBindings(this, "selectButton", selectButton);
	return temp;
}

/**
 * @private
 **/
public function __selectButton_click(event:flash.events.MouseEvent):void
{
	selectFile()
}

private function _gsups_Label1_i() : spark.components.Label
{
	var temp : spark.components.Label = new spark.components.Label();
	temp.x = 122;
	temp.y = 27;
	temp.text = "Select a file to upload...";
	temp.width = 298;
	temp.id = "consoleLabel";
	if (!temp.document) temp.document = this;
	consoleLabel = temp;
	mx.binding.BindingManager.executeBindings(this, "consoleLabel", consoleLabel);
	return temp;
}

/**
 * @private
 **/
public function ___gsups_Application1_creationComplete(event:mx.events.FlexEvent):void
{
	setup();
}




	mx_internal var _gsups_StylesInit_done:Boolean = false;

	mx_internal function _gsups_StylesInit():void
	{
		//	only add our style defs to the style manager once
		if (mx_internal::_gsups_StylesInit_done)
			return;
		else
			mx_internal::_gsups_StylesInit_done = true;
			
		var style:CSSStyleDeclaration;
		var effects:Array;
			        

        var conditions:Array;
        var condition:CSSCondition;
        var selector:CSSSelector;

		styleManager.initProtoChainRoots();
	}




}

}
