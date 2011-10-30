package components 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	public class PhotoshopDrag 
	{
		public var content:Sprite;
		public var overlay:Sprite;
		public var moveFunction:Function;
		
		private var _lastMousePos:Point = new Point();
		private var _spacePressed:Boolean = false;
		private var _moving:Boolean = false;
		
		public function PhotoshopDrag(content:Sprite, func:Function) 
		{
			this.moveFunction = func;
			this.content = content;
			
			if (!content.stage)
				content.addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			else
				handleAddedToStage();
		}
		
		private function handleAddedToStage(e:Event = null):void 
		{
			content.removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			content.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			
			content.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, handleRightMouseDown);
		}
		
		private function initStage():void
		{
			
		}
		
		private function handleKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.SPACE && !_spacePressed)
			{
				createOverlay();
				overlay.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
				content.stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
				Mouse.cursor = MouseCursor.HAND;
				_spacePressed = true;
			}
		}
		
		private function handleKeyUp(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.SPACE)
			{
				if (overlay)
					overlay.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
				content.stage.removeEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
				Mouse.cursor = MouseCursor.AUTO;
				destroyOverlay();
				_spacePressed = false;
			}
		}
		
		private function handleMouseDown(e:MouseEvent):void 
		{
			if (_moving) //This can happen if the canvas is already moving via right mouse button.
				return;
				
			content.stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			content.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			_lastMousePos.x = content.stage.mouseX;
			_lastMousePos.y = content.stage.mouseY;
		}
		
		private function handleRightMouseDown(e:MouseEvent):void
		{
			if (_moving) //This can happen if the canvas is already moving via left mouse button.
				return;
				
			content.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, handleRightMouseUp);
			content.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			_lastMousePos.x = content.stage.mouseX;
			_lastMousePos.y = content.stage.mouseY;
			Mouse.cursor = MouseCursor.HAND;
			createOverlay();
		}
		
		private function handleMouseMove(e:MouseEvent):void 
		{
			var currMousePos:Point =  new Point(content.stage.mouseX, content.stage.mouseY);
			var diff:Point = currMousePos.subtract(_lastMousePos);
			moveFunction(-(content.x + diff.x), -(content.y + diff.y));
			_lastMousePos = currMousePos;
		}
		
		private function handleMouseUp(e:MouseEvent):void 
		{
			content.stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			content.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			_moving = false;
		}
		
		private function handleRightMouseUp(e:MouseEvent):void
		{
			content.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, handleRightMouseUp);
			content.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			Mouse.cursor = MouseCursor.AUTO;
			_moving = false;
			destroyOverlay();
		}
		
		private function createOverlay():void
		{
			if (overlay)
				return;
				
			overlay = new Sprite();
			content.stage.addChild(overlay);
			overlay.graphics.beginFill(0, 0);
			overlay.graphics.drawRect(0, 0, content.stage.width, content.stage.height);
		}
		
		private function destroyOverlay():void
		{
			if (!overlay)
				return;
				
			content.stage.removeChild(overlay);
			overlay = null;
		}
	}

}