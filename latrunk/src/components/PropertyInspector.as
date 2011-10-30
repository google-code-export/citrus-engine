package components 
{
	import components.listitems.LAListItem;
	import components.listitems.PropertyListItem;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class PropertyInspector extends Sprite 
	{
		public var list:LAList;
		public var nameField:TextField;
		public var classField:TextField;
		
		public function PropertyInspector() 
		{
			var nameFieldFormat:TextFormat = new TextFormat("_sans", 18, 0xffffff, true);
			nameField = new TextField();
			addChild(nameField);
			nameField.defaultTextFormat = nameFieldFormat;
			nameField.type = TextFieldType.INPUT;
			nameField.width = 300;
			nameField.height = 30;
			nameField.tabEnabled = false;
			
			var classFieldFormat:TextFormat = new TextFormat("_sans", 12, 0xcccccc, true);
			classField = new TextField();
			addChild(classField);
			classField.defaultTextFormat = classFieldFormat;
			classField.selectable = false;
			classField.width = 250;
			classField.y = 24;
			
			list = new LAList(20, PropertyListItem);
			addChild(list);
			list.y = 50;
			list.addEventListenerToButtons("changeProperty", handlePropertyChange);
			
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		private function handleAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDownWhenNameIsEditable, false, 1);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyUpWhenNameIsEditable, false, 1);
			stage.addEventListener(Event.RESIZE, handleStageResize);
			
			list.numVisibleItems = calculateNumVisibleItems();
		}
		
		private function handleRemovedFromStage(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDownWhenNameIsEditable);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyUpWhenNameIsEditable);
			stage.removeEventListener(Event.RESIZE, handleStageResize);
		}
		
		private function handleKeyDownWhenNameIsEditable(e:KeyboardEvent):void 
		{
			if (stage.focus == nameField)
				e.stopImmediatePropagation();
		}
		
		private function handleKeyUpWhenNameIsEditable(e:KeyboardEvent):void 
		{
			if (stage.focus == nameField)
				e.stopImmediatePropagation();
		}
		
		private function handlePropertyChange(e:Event):void 
		{
			var item:Object = list.getItemByButton(LAListItem(e.target));
			item.value = PropertyListItem(e.target).value;
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