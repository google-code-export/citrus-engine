package components.listitems 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	public class AssetListItem extends LAListItem
	{
		public var background:Sprite;
		public var labelField:TextField;
		
		private var _itemWidth:Number = 300;
		private var _bgColor1:uint = 0x000000;
		private var _bgColor2:uint = 0xcccccc;
		private var _bgAlpha1:Number = .0;
		private var _bgAlpha2:Number = .2;
		private var _textColor:uint = 0xffffff;
		private var _evenIndex:Boolean = false;
		
		public function AssetListItem() 
		{
			super();
			
			tabEnabled = false;
			tabChildren = false;
			
			background = new Sprite();
			addChild(background);
			
			var labelFieldFormat:TextFormat = new TextFormat("_sans", 12, 0xff0000);
			labelField = new TextField();
			addChild(labelField);
			labelField.defaultTextFormat = labelFieldFormat;
			labelField.height = 20;
			labelField.selectable = false;
			labelField.multiline = false;
			
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
		}
		
		public function get label():String
		{
			return labelField.text;
		}
		
		public function set label(value:String):void
		{
			labelField.text = value;
		}
		
		public function get evenIndex():Boolean
		{
			return _evenIndex;
		}
		
		public function set evenIndex(value:Boolean):void
		{
			_evenIndex = value;
		}
		
		private function handleRemovedFromStage(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
		}
		
		override protected function handleRender(e:Event):void
		{			
			labelField.width = _itemWidth;
			labelField.textColor = _textColor;
			
			background.graphics.clear();
			background.graphics.beginFill(_evenIndex ? _bgColor1 : _bgColor2, _evenIndex ? _bgAlpha1 : _bgAlpha2);
			background.graphics.drawRect(0, 0, _itemWidth, 20);
			background.graphics.endFill();
		}
	}

}