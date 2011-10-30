package components 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	public class LoadingOverlay extends Sprite 
	{
		[Embed(source='../../lib/btn_no.png')] private var _btnNoClass:Class;
		
		public var nameField:TextField;
		public var cancelButton:Sprite;
		
		public function LoadingOverlay() 
		{
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			
			var nameFieldFormat:TextFormat = new TextFormat("_sans", 30, 0xffffff, true);
			nameField = new TextField();
			addChild(nameField);
			nameField.defaultTextFormat = nameFieldFormat;
			nameField.tabEnabled = false;
			nameField.autoSize = "center";
			nameField.selectable = false;
			nameField.text = "Please wait...";
			
			var bitmap:Bitmap = new _btnNoClass();
			cancelButton = new Sprite();
			cancelButton.buttonMode = true;
			cancelButton.tabEnabled = false;
			addChild(cancelButton);
			cancelButton.addChild(bitmap);
			cancelButton.addEventListener(MouseEvent.CLICK, handleNoButtonClick);
		}
		
		public function cancel():void
		{
			parent.removeChild(this);
			dispatchEvent(new Event(Event.CANCEL));
		}
		
		private function handleAddedToStage(e:Event):void 
		{
			stage.addEventListener(Event.RESIZE, handleResize);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			
			draw();
		}
		
		private function handleRemovedFromStage(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			stage.removeEventListener(Event.RESIZE, handleResize);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		}
		
		private function handleNoButtonClick(e:MouseEvent):void 
		{
			cancel();
		}
		
		private function handleKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.ESCAPE && cancelButton.visible)
				cancel();
		}
		
		private function handleResize(e:Event):void
		{
			draw();
		}
		
		private function draw():void
		{
			graphics.clear();
			graphics.beginFill(0, 0.6);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
			
			nameField.x = (stage.stageWidth - nameField.width) / 2;
			nameField.y = (stage.stageHeight - nameField.height) / 2;
			
			cancelButton.x = (stage.stageWidth - cancelButton.width) / 2;
			cancelButton.y = nameField.y + nameField.height + 20;
		}
	}

}