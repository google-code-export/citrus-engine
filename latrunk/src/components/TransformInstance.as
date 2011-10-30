package components 
{
	import com.greensock.events.TransformEvent;
	import com.greensock.transform.TransformItem;
	import com.greensock.transform.TransformManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class TransformInstance extends Sprite
	{	
		public var id:uint;
		public var transformItem:TransformItem;
		
		private var _color:uint = 0xffffff;
		private var _alpha:Number = .7;
		
		public function TransformInstance(id:uint, tm:TransformManager) 
		{
			this.id = id;
			transformItem = tm.addItem(this);
		}
		
		override public function get width():Number
		{
			return super.width;
		}
		
		override public function set width(value:Number):void
		{
			drawBounds(value, height);
			super.width = value;
		}
		
		public function get unrotatedWidth():Number
		{
			//Get the actual width of the object
			var actualRotation:Number = rotation;
			rotation = 0;
			var actualWidth:Number = width;
			rotation = actualRotation;
			return actualWidth;
		}
		
		public function set unrotatedWidth(value:Number):void
		{
			var actualRotaton:Number = rotation;
			rotation = 0;
			width = value;
			rotation = actualRotaton;
		}
		
		override public function get height():Number
		{
			return super.height;
		}
		
		override public function set height(value:Number):void
		{
			drawBounds(width, value);
			super.height = value
		}
		
		public function get unrotatedHeight():Number
		{
			//Get the actual height of the object
			var actualRotation:Number = rotation;
			rotation = 0;
			var actualHeight:Number = height;
			rotation = actualRotation;
			return actualHeight;
		}
		
		public function set unrotatedHeight(value:Number):void
		{
			var actualRotaton:Number = rotation;
			rotation = 0;
			height = value;
			rotation = actualRotaton;
		}
		
		private function drawBounds(width:Number, height:Number):void
		{
			var boundsX:Number = 0;
			var boundsY:Number = 0;
			
			var w:Number = width ? width : 1;
			var h:Number = height ? height : 1;
			
			graphics.clear();
			graphics.beginFill(_color, _alpha);
			graphics.drawRect(-width / 2,  -height / 2, w, h);
			graphics.endFill();
		}
	}

}