package com.citrusengine.utils {

	import org.osflash.signals.Signal;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;

	/**
	 * The LevelManager is a complex but powerful class, you can use simple states for levels or/with SWC/SWF.
	 * Before using it, be sure that you have good OOP knowledge. For using it, you must use an Abstract state class 
	 * that you give as constructor parameter : Alevel. 
	 * 
	 * The three ways to set up your level : 
	 * <code>_levelManager.levels = [Level1, Level2];
	 * _levelManager.levels = [[Level1, Level1_SWC], [level2, Level2_SWC]];
	 * _levelManager.levels = [[Level1, "level1.swf"], [level2, "level2.swf"]];</code>
	 * 
	 * An instanciation exemple in your Main class:
	 * <code>_levelManager = new LevelManager(ALevel);
	 * _levelManager.onLevelChanged.add(_onLevelChanged);
	 * _levelManager.levels = [Level1, Level2];
	 * _levelManager.gotoLevel();</code>
	 * 
	 * The _onLevelChanged function gives in parameter the Alevel that you associate to your state : <code>state = lvl;</code>
	 * Then you can associate other function :
	 * <code>lvl.lvlEnded.add(_nextLevel);
	 * lvl.restartLevel.add(_restartLevel);</code>
	 * And their result :
	 * <code>_levelManager.nextLevel();
	 * state = _levelManager.currentLevel as IState;</code>
	 * 
	 * The ALevel class must implement public var lvlEnded & restartLevel Signals in its constructor.
	 * If you have associated a SWF or SWC file to your level, you must add a flash MovieClip to its constructor.
	 */
	public class LevelManager {

		static private var _instance:LevelManager;

		public var onLevelChanged:Signal;
		
		private var _ALevel:Class;
		private var _levels:Array;
		private var _currentIndex:uint;
		private var _currentLevel:Object;

		public function LevelManager(ALevel:Class) {

			_instance = this;
			
			_ALevel = ALevel;

			onLevelChanged = new Signal(_ALevel);
			_currentIndex = 0;
		}

		static public function getInstance():LevelManager {
			return _instance;
		}


		public function destroy():void {
			
			onLevelChanged.removeAll();
			
			_currentLevel = null;
		}

		public function nextLevel():void {

			if (_currentIndex < _levels.length - 1) {
				++_currentIndex;
			}

			gotoLevel();
		}

		public function prevLevel():void {

			if (_currentIndex > 0) {
				--_currentIndex;
			}

			gotoLevel();
		}

		/**
		 * Call gotoLevel() function to the LevelManager instance to launch your first level, or you may specify it.
		 */
		public function gotoLevel(index:int = -1):void {

			if (_currentLevel != null) {
				_currentLevel.lvlEnded.remove(_onLevelEnded);
			}

			var loader:Loader = new Loader();

			if (index != -1) {
				_currentIndex = index - 1;
			}

			// Level SWF and SWC are undefined
			if (_levels[_currentIndex][0] == undefined) {

				_currentLevel = _ALevel(new _levels[_currentIndex]);
				_currentLevel.lvlEnded.add(_onLevelEnded);

				onLevelChanged.dispatch(_currentLevel);
				
			// It's a SWC ?
			} else if (_levels[_currentIndex][1] is Class) {
				
				_currentLevel = _ALevel(new _levels[_currentIndex][0](new _levels[_currentIndex][1]()));
				_currentLevel.lvlEnded.add(_onLevelEnded);
				
				onLevelChanged.dispatch(_currentLevel);
				
			// 	So it's a SWF
			} else {

				loader.load(new URLRequest(_levels[_currentIndex][1]));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,_levelSWFLoaded);
			}
		}

		private function _levelSWFLoaded(evt:Event):void {

			_currentLevel = _ALevel(new _levels[_currentIndex][0](evt.target.loader.content));
			_currentLevel.lvlEnded.add(_onLevelEnded);

			onLevelChanged.dispatch(_currentLevel);

			evt.target.removeEventListener(Event.COMPLETE,_levelSWFLoaded);
			evt.target.loader.unloadAndStop();
		}

		private function _onLevelEnded():void {

		}
		
		public function set levels(levels:Array):void {
			_levels = levels;
		}

		public function get currentLevel():Object {
			return _currentLevel;
		}

		public function set currentLevel(currentLevel:Object):void {
			_currentLevel = currentLevel;
		}

		public function get nameCurrentLevel():String {
			return _currentLevel.nameLevel;
		}

	}
}