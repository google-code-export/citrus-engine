package components 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	public class PopUp extends Sprite
	{
		[Embed(source = '../../lib/btn_close.png')] private var _btnCloseClass:Class;
		[Embed(source = '../../lib/btn_no.png')] private var _btnNoClass:Class;
		[Embed(source = '../../lib/btn_yes.png')] private var _btnYesClass:Class;
		
		public var overlay:Sprite;
		public var content:Sprite;
		public var closeButton:Sprite;
		public var noButton:Sprite;
		public var yesButton:Sprite;
		
		public function PopUp(content:Sprite, yesNo:Boolean) 
		{
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			addEventListener(Event.REMOVED, handleRemoved);
			
			overlay = new Sprite();
			addChild(overlay);
			overlay.tabEnabled = false;
			
			this.content = content;
			addChild(content);
			
			var bitmap:Bitmap = new _btnCloseClass();
			closeButton = new Sprite();
			closeButton.buttonMode = true;
			closeButton.tabEnabled = false;
			addChild(closeButton);
			closeButton.addChild(bitmap);
			closeButton.addEventListener(MouseEvent.CLICK, handleCloseButtonClick);
			
			if (yesNo)
			{
				bitmap = new _btnNoClass();
				noButton = new Sprite();
				noButton.buttonMode = true;
				noButton.tabEnabled = false;
				addChild(noButton);
				noButton.addChild(bitmap);
				noButton.addEventListener(MouseEvent.CLICK, handleNoButtonClick);
				
				bitmap = new _btnYesClass();
				yesButton = new Sprite();
				yesButton.buttonMode = true;
				yesButton.tabEnabled = false;
				addChild(yesButton);
				yesButton.addChild(bitmap);
				yesButton.addEventListener(MouseEvent.CLICK, handleYesButtonClick);
			}
		}
		
		private function handleAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.addEventListener(Event.RESIZE, handleStageResize);
			
			draw();
		}
		
		private function handleRemoved(e:Event):void 
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.removeEventListener(Event.RESIZE, handleStageResize);
		}
		
		private function handleKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.ENTER && yesButton)
			{
				parent.removeChild(this);
				dispatchEvent(new Event("responseYes"));
			}
			else if (e.keyCode == Keyboard.ESCAPE)
			{
				parent.removeChild(this);
				dispatchEvent(new Event("reponseCancel"));
			}
		}
		
		private function handleStageResize(e:Event):void
		{
			draw();
		}
		
		protected function draw():void
		{
			overlay.graphics.clear();
			overlay.graphics.beginFill(0, .5);
			overlay.graphics.drawRect(0, 0, stage.width, stage.height);
			overlay.graphics.endFill();
			
			content.x = (stage.stageWidth - content.width) / 2;
			content.y = (stage.stageHeight - content.height) / 2;
			
			closeButton.x = content.x + content.width - closeButton.width - 12;
			closeButton.y = content.y + 12;
			
			if (yesButton && noButton)
			{
				yesButton.x = content.x;
				yesButton.y = content.y + content.height + 12;
				
				noButton.x = content.x + yesButton.width + 12;
				noButton.y = content.y + content.height + 12;
			}
		}
		
		private function handleCloseButtonClick(e:MouseEvent):void 
		{
			parent.removeChild(this);
			dispatchEvent(new Event("responseCancel"));
		}
		
		private function handleNoButtonClick(e:MouseEvent):void 
		{
			parent.removeChild(this);
			dispatchEvent(new Event("responseCancel"));
		}
		
		private function handleYesButtonClick(e:MouseEvent):void 
		{
			parent.removeChild(this);
			dispatchEvent(new Event("responseYes"));
		}
	}

}