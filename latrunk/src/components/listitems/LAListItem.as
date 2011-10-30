package components.listitems 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class LAListItem extends Sprite
	{
		private var _state:String = "normal";
		private var _previousState:String = "normal";
		
		public function LAListItem() 
		{
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		private function handleAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			stage.addEventListener(Event.RENDER, handleRender);
		}
		
		public function get previousState():String
		{
			return _previousState;
		}
		
		public function get state():String
		{
			return _state;
		}
		
		public function set state(value:String):void
		{
			if (_state == value)
				return;
			
			_previousState = _state;
			_state = value;
			update();
			dispatchEvent(new Event("stateChange"));
		}
		
		public function update():void
		{
			if (stage)
				stage.invalidate();
		}
		
		protected function handleRender(e:Event):void
		{
			
		}
	}

}