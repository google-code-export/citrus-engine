package com.citrusengine.core {

	import starling.core.Starling;

	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * CitrusEngine is the top-most class in the library. When you start your project, you should make your
	 * document class extend this class.
	 * 
	 * <p>CitrusEngine is a singleton so that you can grab a reference to it anywhere, anytime. Don't abuse this power,
	 * but use it wisely. With it, you can quickly grab a reference to the manager classes such as current State, Input and SoundManager.</p>
	 */	
	public class CitrusEngine extends MovieClip
	{
		public static const VERSION:String = "3.00.00";
		
		private static var _instance:CitrusEngine;
		
		private var _state:*;
		private var _newState:*;
		private var _stateDisplayIndex:uint = 0;
		private var _startTime:Number;
		private var _gameTime:Number;
		private var _playing:Boolean = true;
		private var _input:Input;
		private var _sound:SoundManager;
		private var _console:Console;
		
		private var _starlingAntialiasing:uint = 1;
		
		public static function getInstance():CitrusEngine
		{
			return _instance;
		}
		
		/**
		 * Flash's innards should be calling this, because you should be extending your document class with it.
		 */		
		public function CitrusEngine()
		{
			_instance = this;
			
			//Set up console
			_console = new Console(9); //Opens with tab key by default
			_console.onShowConsole.add(handleShowConsole);
			_console.addCommand("set", handleConsoleSetCommand);
			addChild(_console);
			
			//timekeeping
			_startTime = new Date().time;
			_gameTime = _startTime;
			
			//Set up input
			_input = new Input();
			
			//Set up sound manager
			_sound = SoundManager.getInstance();
			
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		/**
		 * A reference to the active game state. Acutally, that's not entirely true. If you've recently changed states and a tick
		 * hasn't occured yet, then this will reference your new state; this is because actual state-changes only happen pre-tick.
		 * That way you don't end up changing states in the middle of a state's tick, effectively fucking stuff up. 
		 */		
		public function get state():*
		{			
			if (_newState)
				return _newState;
			else {
				if (_state is Starling)
					return (_state.stage.getChildAt(0) as StarlingState);
				else
					return _state;
			}
		}
		
		/**
		 * We only ACTUALLY change states on enter frame so that we don't risk changing states in the middle of a state update.
		 * However, if you use the state getter, it will grab the new one for you, so everything should work out just fine.
		 */		
		public function set state(value:*):void
		{
			_newState = value;
			if (_newState is Starling) {
				_newState.antiAliasing = _starlingAntialiasing;
			}
		}
		
		/**
		 * Runs and pauses the game loop. Assign this to false to pause the game and stop the
		 * <code>update()</code> methods from being called. 
		 */		
		public function get playing():Boolean
		{
			return _playing;
		}
		
		public function set playing(value:Boolean):void
		{
			_playing = value;
			if (_playing)
				_gameTime = new Date().time;
		}
		
		/**
		 * You can get to my Input manager object from this reference so that you can see which keys are pressed and stuff. 
		 */		
		public function get input():Input
		{
			return _input;
		}
		
		/**
		 * A reference to the SoundManager instance. Use it if you want.
		 */		
		public function get sound():SoundManager
		{
			return _sound;
		}
		
		/**
		 * A reference to the console, so that you can add your own console commands. See the class documentation for more info.
		 * The console can be opened by pressing the tilde key (It looks like this: "~" right below the escape key).
		 * There is one console command built-in by default, but you can add more by using the addCommand() method.
		 * 
		 * <p>To try it out, try using the "set" command to change a property on a CitrusObject. You can toggle Box2D's
		 * debug draw visibility like this "set Box2D visible false". If your Box2D CitrusObject instance is not named
		 * "Box2D", use the name you gave it instead.</p>
		 */		
		public function get console():Console
		{
			return _console;
		}
		
		public function get starlingAntialiasing():uint {
			return _starlingAntialiasing;
		}

		public function set starlingAntialiasing(starlingAntialiasing:uint):void {
			_starlingAntialiasing = starlingAntialiasing;
		}
		
		/**
		 * Set up things that need the stage access.
		 */
		private function handleAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			stage.scaleMode = "noScale";
			stage.align = "topLeft";
			stage.addEventListener(Event.DEACTIVATE, handleStageDeactivated);
			
			_input.initialize();
		}
		
		/**
		 * This is the game loop. It switches states if necessary, then calls update on the current state.
		 */		
		//TODO The CE updates use the timeDelta to keep consistent speed during slow framerates. However, Box2D becomes unstable when changing timestep. Why?
		private function handleEnterFrame(e:Event):void
		{
			//Change states if it has been requested
			if (_newState)
			{
				if (_state)
				{
					if (_state is Starling) {
						(_state.stage.getChildAt(0) as StarlingState).destroy();
					} else {
						_state.destroy();
						removeChild(_state as State);
					}
				}
				_state = _newState;
				_newState = null;
				
				if (_state is Starling) {
					_state.start();
					(_state.stage.getChildAt(0) as StarlingState).initialize();
				} else {
					addChildAt(_state as State, _stateDisplayIndex);
					_state.initialize();
				}
				
			}
			
			//Update the state
			if (_state && _playing)
			{
				var nowTime:Number = new Date().time;
				var timeSinceLastFrame:Number = nowTime - _gameTime;
				var timeDelta:Number = timeSinceLastFrame / 1000;
				_gameTime = nowTime;
				
				if (_state is Starling)
					(_state.stage.getChildAt(0) as StarlingState).update(timeDelta);
				else
					_state.update(timeDelta);
			}
			
		}
		
		private function handleStageDeactivated(e:Event):void
		{
			if (_playing)
			{
				playing = false;
				stage.addEventListener(Event.ACTIVATE, handleStageActivated);
			}
		}
		
		private function handleStageActivated(e:Event):void
		{
			playing = true;
			stage.removeEventListener(Event.ACTIVATE, handleStageActivated);
		}
		
		private function handleShowConsole():void
		{
			if (_input.enabled)
			{
				_input.enabled = false;
				_console.onHideConsole.addOnce(handleHideConsole);
			}
		}
		
		private function handleHideConsole():void
		{
			_input.enabled = true;
		}
		
		private function handleConsoleSetCommand(objectName:String, paramName:String, paramValue:String):void
		{
			var object:CitrusObject;
			
			if (_state is Starling)
			 	object = (_state.stage.getChildAt(0) as StarlingState).getObjectByName(objectName);
			else
				object = _state.getObjectByName(objectName);
			if (!object)
			{
				trace("Warning: There is no object named " + objectName);
				return;
			}
			
			var value:Object;
			if (paramValue == "true")
				value = true;
			else if (paramValue == "false")
				value = false;
			else
				value = paramValue;
			
			if (object.hasOwnProperty(paramName))
			{
				object[paramName] = value;
			}
			else
			{
				trace("Warning: " + objectName + " has no parameter named " + paramName + ".");
			}
		}
	}
}