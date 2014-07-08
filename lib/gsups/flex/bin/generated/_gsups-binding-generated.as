

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import spark.components.Label;
import spark.components.Button;

class BindableProperty
{
	/*
	 * generated bindable wrapper for property consoleLabel (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'consoleLabel' moved to '_664954845consoleLabel'
	 */

    [Bindable(event="propertyChange")]
    public function get consoleLabel():spark.components.Label
    {
        return this._664954845consoleLabel;
    }

    public function set consoleLabel(value:spark.components.Label):void
    {
    	var oldValue:Object = this._664954845consoleLabel;
        if (oldValue !== value)
        {
            this._664954845consoleLabel = value;
           if (this.hasEventListener("propertyChange"))
               this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "consoleLabel", oldValue, value));
        }
    }

	/*
	 * generated bindable wrapper for property selectButton (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'selectButton' moved to '_1555143502selectButton'
	 */

    [Bindable(event="propertyChange")]
    public function get selectButton():spark.components.Button
    {
        return this._1555143502selectButton;
    }

    public function set selectButton(value:spark.components.Button):void
    {
    	var oldValue:Object = this._1555143502selectButton;
        if (oldValue !== value)
        {
            this._1555143502selectButton = value;
           if (this.hasEventListener("propertyChange"))
               this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "selectButton", oldValue, value));
        }
    }



}
