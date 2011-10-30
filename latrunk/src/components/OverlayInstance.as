package components 
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class OverlayInstance extends Sprite
	{
		public var graphic:Loader;
		public var mapObject:MapObjectInstance;
		
		private var _offsetX:Number = 0;
		private var _offsetY:Number = 0;
		private var _registration:String = "topLeft";
		private var _view:String = "";
		
		public function OverlayInstance() 
		{
			super();
			mouseEnabled = false;
			mouseChildren = false;
			
			graphic = new Loader();
			addChild(graphic);
			graphic.contentLoaderInfo.addEventListener(Event.COMPLETE, handleGraphicLoaded);
		}
		
		public function get offsetX():Number
		{
			return _offsetX;
		}
		
		public function set offsetX(value:Number):void
		{
			_offsetX = value;
			updateGraphicPosition();
		}
		
		public function get offsetY():Number
		{
			return _offsetY;
		}
		
		public function set offsetY(value:Number):void
		{
			_offsetY = value;
			updateGraphicPosition();
		}
		
		public function get registration():String
		{
			return _registration;
		}
		
		public function set registration(value:String):void
		{
			_registration = value;
			updateGraphicPosition();
		}
		
		public function get view():String
		{
			return _view;
		}
		
		public function set view(value:String):void
		{
			_view = value;
			graphic.load(new URLRequest(value));
		}
		
		private function handleGraphicLoaded(e:Event):void 
		{
			updateGraphicPosition();
		}
		
		private function updateGraphicPosition():void
		{
			if (_registration == "topLeft")
			{
				graphic.x = _offsetX;
				graphic.y = _offsetY;
			}
			else
			{
				graphic.x = -(graphic.width / 2) + _offsetX;
				graphic.y = -(graphic.height / 2) + _offsetY;
			}
		}
	}

}