package components 
{
	import components.listitems.AssetListItem;
	import components.listitems.LAListItem;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class AssetList extends Sprite 
	{
		public var list:LAList;
		public var classField:TextField;
		public var dropMap:Map;
		public var draggingItem:Bitmap;
		public var placementPoint:Point;
		
		private var _draggingIndex:int = -1;
		private var _dragOffset:Point;
		
		public function AssetList(dropMap:Map) 
		{
			this.dropMap = dropMap;
			
			var classFieldFormat:TextFormat = new TextFormat("_sans", 12, 0xcccccc, true);
			classField = new TextField();
			addChild(classField);
			classField.defaultTextFormat = classFieldFormat;
			classField.selectable = false;
			classField.width = 250;
			classField.text = "Drag to create an object.";
			
			list = new LAList(20, AssetListItem);
			addChild(list);
			list.y = 30;
			list.addEventListenerToButtons(MouseEvent.MOUSE_DOWN, handleListItemPress);
			
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		private function handleAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			stage.addEventListener(Event.RESIZE, handleStageResize);
		}
		
		private function handleRemovedFromStage(e:Event):void
		{
			stage.removeEventListener(Event.RESIZE, handleStageResize);
		}
		
		public function get draggingIndex():uint
		{
			return _draggingIndex;
		}
		
		private function handleListItemPress(e:MouseEvent):void 
		{
			var listItem:LAListItem = e.currentTarget as LAListItem;
			
			_draggingIndex = list.getIndexOfButton(listItem);
			
			_dragOffset = new Point(listItem.mouseX, listItem.mouseY);
			
			var bData:BitmapData = new BitmapData(listItem.width, listItem.height, true, 0xff0000);
			bData.draw(listItem);
			draggingItem = new Bitmap(bData);
			draggingItem.alpha = 1;
			stage.addChild(draggingItem);
			draggingItem.x = stage.mouseX - _dragOffset.x;
			draggingItem.y = stage.mouseY - _dragOffset.y;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleDragMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleDragRelease);
			dropMap.addEventListener(MouseEvent.MOUSE_UP, handleDrop);
		}
		
		private function handleDragMove(e:MouseEvent):void 
		{
			draggingItem.x = stage.mouseX - _dragOffset.x;
			draggingItem.y = stage.mouseY - _dragOffset.y;
		}
		
		private function handleDragRelease(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleDragMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleDragRelease);
			dropMap.removeEventListener(MouseEvent.MOUSE_UP, handleDrop);
			
			stage.removeChild(draggingItem);
			draggingItem = null;
		}
		
		private function handleDrop(e:MouseEvent):void 
		{
			placementPoint = dropMap.mapMousePosition;
			dispatchEvent(new Event("create"));
		}
		
		private function handleStageResize(e:Event):void 
		{
			list.numVisibleItems = calculateNumVisibleItems();
		}
		
		private function calculateNumVisibleItems():Number
		{
			var listGlobalTop:Number = list.localToGlobal(new Point()).y;
			var listGlobalBottom:Number = stage.stageHeight - 30;
			var diff:Number = listGlobalBottom - listGlobalTop;
			return Math.max(1, Math.floor(diff / list.getChildAt(0).height));
		}
	}

}