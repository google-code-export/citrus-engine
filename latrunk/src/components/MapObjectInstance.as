package components 
{
	import com.greensock.events.TransformEvent;
	import com.greensock.transform.TransformItem;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class MapObjectInstance extends EventDispatcher
	{
		public var overlay:OverlayInstance;
		public var transform:TransformInstance;
		public var id:uint;
		
		private var _parallax:Number = 1;
		private var _group:Number = 0;
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var _rotation:Number = 0;
		private var _view:String;
		private var _registration:String;
		
		public function MapObjectInstance(id:uint, overlay:OverlayInstance, transform:TransformInstance) 
		{
			this.id = id;
			this.overlay = overlay;
			this.overlay.mapObject = this;
			this.transform = transform;
			
			transformItem.addEventListener(TransformEvent.MOVE, handleTransform, false, 0, true);
			transformItem.addEventListener(TransformEvent.SCALE, handleTransform, false, 0, true);
			transformItem.addEventListener(TransformEvent.ROTATE, handleRotation, false, 0, true);
		}
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(value:Number):void
		{
			if (_x == value)
				return;
				
			_x = value;
			dispatchEvent(new Event("positionDirty"));
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			if (_y == value)
				return;
				
			_y = value;
			dispatchEvent(new Event("positionDirty"));
		}
		
		public function get width():Number
		{
			return _width;
		}
		
		public function set width(value:Number):void
		{
			if (_width == value)
				return;
				
			_width = value;
			dispatchEvent(new Event("scaleDirty"));
		}
		
		public function get height():Number
		{
			return _height
		}
		
		public function set height(value:Number):void
		{
			if (_height == value)
				return;
				
			_height = value;
			dispatchEvent(new Event("scaleDirty"));
		}
		
		public function get rotation():Number
		{
			return _rotation;
		}
		
		public function set rotation(value:Number):void
		{
			if (_rotation == value)
				return;
				
			_rotation = value;
			dispatchEvent(new Event("rotationDirty"));
		}
		
		public function get offsetX():Number
		{
			return overlay.offsetX;
		}
		
		public function set offsetX(value:Number):void
		{
			overlay.offsetX = value;
		}
		
		public function get offsetY():Number
		{
			return overlay.offsetY;
		}
		
		public function set offsetY(value:Number):void
		{
			overlay.offsetY = value;
		}
		
		public function get view():String
		{
			return _view;
		}
		
		public function set view(value:String):void
		{
			if (_view == value)
				return;
				
			_view = value;
			dispatchEvent(new Event("viewDirty"));
		}
		
		public function get transformItem():TransformItem
		{
			return transform.transformItem;
		}
		
		public function get parallax():Number
		{
			return _parallax;
		}
		
		public function set parallax(value:Number):void
		{
			_parallax = value;
		}
		
		public function get group():Number
		{
			return _group;
		}
		
		public function set group(value:Number):void
		{
			if (_group == value)
				return;
				
			_group = value;
			dispatchEvent(new Event("groupDirty"));
		}
		
		public function get registration():String 
		{
			return _registration;
		}
		
		public function set registration(value:String):void 
		{
			_registration = value;
			overlay.registration = value;
		}
		
		private function handleTransform(e:TransformEvent):void 
		{
			overlay.x = transform.x;
			overlay.y = transform.y;
		}
		
		private function handleRotation(e:TransformEvent):void
		{
			overlay.rotation = transform.rotation;
		}
	}

}