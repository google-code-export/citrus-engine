package citrus.input.controllers.gamepad
{
	import citrus.input.controllers.gamepad.controls.ButtonController;
	import citrus.input.controllers.gamepad.controls.Icontrol;
	import citrus.input.controllers.gamepad.controls.StickController;
	import citrus.input.controllers.gamepad.maps.GamePadMap;
	import citrus.input.InputController;
	import flash.events.Event;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	
	public class Gamepad extends InputController
	{
		protected var _device:GameInputDevice;
		protected var _deviceID:String;
		
		/**
		 * GameInputControls for the GameInputDevice, indexed by their id.
		 */
		protected var _controls:Dictionary;
		
		/**
		 * button controller used, indexed by name.
		 */
		protected var _buttons:Dictionary;
		
		/**
		 * stick controller used, indexed by name.
		 */
		protected var _sticks:Dictionary;
		
		/**
		 * controls being used, indexed by GameInputControl.id
		 * (quick access for onChange)
		 */
		protected var _usedControls:Dictionary;
		
		/**
		 * will trace information on the gamepad at runtime.
		 */
		public var debug:Boolean = false;
		
		/**
		 * if set to true, all 'children controllers' will send an action with their controller name when active (value != 0) 
		 * helps figuring out which button someone touches for remapping in game for example.
		 */
		public var triggerActivity:Boolean = true;
		
		public function Gamepad(name:String, device:GameInputDevice, map:Class = null, params:Object = null)
		{
			super(name, params);
			
			_device = device;
			_deviceID = _device.id;
			_controls = new Dictionary();
			
			enabled = true;
			initControlsList();
			
			_buttons = new Dictionary();
			_sticks = new Dictionary();
			
			_usedControls = new Dictionary();
		}
		
		/**
		 * list all available controls by their control.id and start caching.
		 */
		protected function initControlsList():void
		{
			var controlNames:Vector.<String> = new Vector.<String>();
			var control:GameInputControl;
			var i:int = 0;
			var numcontrols:int = _device.numControls;
			for (i; i < numcontrols; i++)
			{
				control = _device.getControlAt(i);
				_controls[control.id] = control;
				controlNames.push(control.id);
			}
			
			_device.startCachingSamples(30, controlNames);
		}
		
		/**
		 * apply GamepadMap
		 * @param	map
		 */
		public function useMap(map:Class):void
		{
			if (map != null)
			{
				var typeXML:XML = describeType(map);
				if (typeXML.factory.extendsClass.(@type == "citrus.input.controllers.gamepad.maps::GamePadMap").length() > 0)
				{
					var mapconfig:GamePadMap = new map();
					mapconfig.setup(this);
					
					if(debug)
					trace(name, "using map", map);
				}
				else if (debug)
					trace(this, "unable to use the ", map, "map.");
			}
			
			stopAllActions();
		}
		
		protected function onChange(e:Event):void
		{
			if (!(e.currentTarget.id in _usedControls))
			{
				if(debug)
					trace(e.target.id, "seems to not be bound to any controls for", this);
				return;
			}
			
			var id:String = (e.currentTarget as GameInputControl).id;
			var value:Number = (e.currentTarget as GameInputControl).value;
			
			var icontrols:Vector.<Icontrol> = _usedControls[id];
			var icontrol:Icontrol;
			
			for each (icontrol in icontrols)
					icontrol.updateControl(id, value);
		
		}
		
		protected function bindControl(controlid:String, controller:Icontrol):void
		{
			if (!(controlid in _controls))
			{
				if(debug)
					trace(this, "trying to bind", controlid, "but", controlid, "is not in listed controls for device", _device.name);
				return;
			}
			
			var control:GameInputControl = (_controls[controlid] as GameInputControl);
			
			if (!control.hasEventListener(Event.CHANGE))
				control.addEventListener(Event.CHANGE, onChange);
			
			if (!(controlid in _usedControls))
				_usedControls[controlid] = new Vector.<Icontrol>();
			
			if(debug)
				trace("Binding", control.id, "to", controller, controlid in _usedControls);
			
			(_usedControls[controlid] as Vector.<Icontrol>).push(controller);
		}
		
		protected function unbindControl(controlid:String, controller:Icontrol):void
		{
			if (!(controlid in _usedControls))
			{
				if (_usedControls[controlid] is Vector.<Icontrol>)
				{
					var controls:Vector.<Icontrol> = _usedControls[controlid];
					var icontrol:Icontrol;
					var i:String;
					for (i in controls)
					{
						icontrol = controls[int(i)];
						if (icontrol == controller)
						{
							controls.splice(int(i), 1);
							break;
						}
					}
					
					if (controls.length == 0)
					{
						delete _usedControls[controlid];
						
						if (_controls[controlid].hasEventListener(Event.CHANGE, onChange))
							_controls[controlid].removeEventListener(Event.CHANGE, onChange);
					}
				}
			}
		}
		
		public function unregisterStick(name:String):void
		{
			var stick:StickController;
			stick = _sticks[name];
			if (stick)
			{
				unbindControl(stick.hAxis, stick);
				unbindControl(stick.vAxis, stick);
				delete _sticks[name];
				stick.destroy();
			}
		}
		
		public function unregisterButton(name:String):void
		{
			var button:ButtonController;
			button = _buttons[name];
			if (button)
			{
				unbindControl(button.controlID, button);
				delete _buttons[name];
				button.destroy();
			}
		}
		
		/**
		 * Register a new stick controller to the gamepad.
		 * leave all or any of up/right/down/left actions to null for these directions to trigger nothing.
		 * invertX and invertY inverts the axis values.
		 * @param	name
		 * @param	hAxis the GameInputControl id for the horizontal axis (left to right).
		 * @param	vAxis the GameInputControl id for the vertical axis (up to donw).
		 * @param	up
		 * @param	right
		 * @param	down
		 * @param	left
		 * @param	invertX
		 * @param	invertY
		 * @return
		 */
		public function registerStick(name:String, hAxis:String, vAxis:String, up:String = null, right:String = null, down:String = null, left:String = null, invertX:Boolean = false, invertY:Boolean = false):StickController
		{
			if (name in _sticks)
			{
				if(debug)
					trace(this + " joystick control " + name + " already exists");
				return _sticks[name];
			}
			
			var joy:StickController = new StickController(name,this, hAxis, vAxis, up, right, down, left, invertX, invertY);
			bindControl(hAxis, joy);
			bindControl(vAxis, joy);
			return _sticks[name] = joy;
		}
		
		/**
		 * Register a new button controller to the gamepad.
		 * if action is null, this button will trigger no action.
		 * @param	name
		 * @param	control_id the GameInputControl id.
		 * @param	action
		 * @return
		 */
		public function registerButton(name:String, control_id:String, action:String = null):ButtonController
		{
			if (name in _buttons)
			{
				if(debug)
					trace(this + " button control " + name + " already exists");
				return _buttons[name];
			}
			var button:ButtonController = new ButtonController(name,this, control_id, action);
			bindControl(control_id, button);
			return _buttons[name] = button;
		}
		
		
		/**
		 * Set a registered stick's actions, leave null to keep unchanged.
		 * @param	name
		 * @param	up
		 * @param	right
		 * @param	down
		 * @param	left
		 */
		public function setStickActions(name:String, up:String, right:String, down:String, left:String):void
		{
			if (!(name in _sticks))
			{
				trace(this,"cannot set joystick control,",name,"is not registered.");
				return;
			}
			
			var joy:StickController = _sticks[name] as StickController;
			
			if (up)
				joy.upAction = up;
			if (right)
				joy.rightAction = right;
			if (down)
				joy.downAction = down;
			if (left)
				joy.leftAction = left;
		}
		
		/**
		 * Set a registered button controller action.
		 * @param	name 
		 * @param	action
		 */
		public function setButtonAction(name:String, action:String):void
		{
			if (!(name in _buttons))
			{
				throw new Error(this + " cannot set button control, " + name + " is not registered.");
			}
			
			(_buttons[name] as ButtonController).action = action;
		}
		
		/**
		 * get registered stick as a StickController to get access to the angle of the joystick for example.
		 * @param	name
		 * @return
		 */
		public function getStick(name:String):StickController
		{
			if (name in _sticks)
				return _sticks[name] as StickController;
			return null;
		}
		
		/**
		 * get added button as a ButtonController
		 * @param	name
		 * @return
		 */
		public function getButton(name:String):ButtonController
		{
			if (name in _buttons)
				return _buttons[name] as ButtonController;
			return null;
		}
		
		public function get device():GameInputDevice
		{
			return _device;
		}
		
		public function get deviceID():String
		{
			return _deviceID;
		}
		
		public function stopAllActions():void
		{
			var icontrols:Vector.<Icontrol>;
			var icontrol:Icontrol;
			
			for each (icontrols in _usedControls)
				for each (icontrol in icontrols)
					_ce.input.stopActionsOf(icontrol as InputController);
		}
		
		override public function set enabled(val:Boolean):void
		{
			_device.enabled = _enabled = val;
		}
		
		override public function destroy():void
		{
			var control:Icontrol;
			for each (control in _buttons)
				unregisterButton((control as InputController).name);
			for each (control in _sticks)
				unregisterButton((control as InputController).name);
			
			_usedControls = null;
			_controls = null;
			
			enabled = false;
			
			_input.stopActionsOf(this);
			
			_buttons = null;
			_sticks = null;
			
			super.destroy();
		
		}
	
	}
}