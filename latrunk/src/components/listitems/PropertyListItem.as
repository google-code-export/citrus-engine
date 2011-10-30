package components.listitems 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	public class PropertyListItem extends LAListItem
	{
		[Embed(source = '../../../lib/btn_propertybrowse.png')] private var _btnPropertyBrowseClass:Class;
		public var background:Sprite;
		public var labelField:TextField;
		public var inputField:TextField;
		public var propertyBrowseButton:Sprite;
		
		private var _itemWidth:Number = 300;
		private var _itemHeight:Number = 20;
		private var _bgColor1:uint = 0xffffff;
		private var _bgColor2:uint = 0xcccccc;
		private var _bgAlpha1:Number = 0;
		private var _bgAlpha2:Number = .3;
		private var _bgSelectedColor:uint = 0xff0000;
		private var _bgSelectedAlpha:Number = .75;
		private var _textNormalColor:uint = 0xffffff;
		private var _textSelectedColor:uint = 0xcccccc;
		private var _evenIndex:Boolean = false;
		private var _previousValue:String;
		private var _inherited:Boolean = false;
		private var _browse:Boolean = false;
		
		public function PropertyListItem() 
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
			labelField.height = _itemHeight;
			labelField.selectable = false;
			labelField.multiline = false;
			
			var inputFieldFormat:TextFormat = new TextFormat("_sans", 12, 0xff0000);
			inputField = new TextField();
			addChild(inputField);
			inputField.width = 150;
			inputField.addEventListener(FocusEvent.FOCUS_IN, handleInputFieldFocus, false, 0, true);
			inputField.addEventListener(FocusEvent.FOCUS_OUT, handleInputFieldBlur, false, 0, true);
			inputField.defaultTextFormat = inputFieldFormat;
			inputField.type = TextFieldType.INPUT;
			inputField.multiline = false;
			inputField.height = _itemHeight;
			
			var bitmap:Bitmap = new _btnPropertyBrowseClass();
			propertyBrowseButton = new Sprite();
			addChild(propertyBrowseButton);
			propertyBrowseButton.addChild(bitmap);
			propertyBrowseButton.buttonMode = true;
			propertyBrowseButton.addEventListener(MouseEvent.CLICK, handlePropertyBrowseClick);
			propertyBrowseButton.visible = _browse;
			
			addEventListener("stateChange", handleStateChange, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
		}
		
		public function get label():String
		{
			return labelField.text;
		}
		
		public function set label(value:String):void
		{
			labelField.text = _inherited ? "    " + value : value;
		}
		
		public function get value():String
		{
			return inputField.text;
		}
		
		public function set value(value:String):void
		{
			if (value)
			{
				inputField.text = value;
			}
			else
				inputField.text = "";
		}
		
		public function get evenIndex():Boolean
		{
			return _evenIndex;
		}
		
		public function set evenIndex(value:Boolean):void
		{
			_evenIndex = value;
		}
		
		public function get inherited():Boolean
		{
			return _inherited;
		}
		
		public function set inherited(value:Boolean):void
		{
			_inherited = value;
		}
		
		public function get browse():Boolean
		{
			return _browse;
		}
		
		public function set browse(value:Boolean):void
		{
			_browse = value;
		}
		
		private function handleRemovedFromStage(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyPress);
		}
		
		override protected function handleRender(e:Event):void
		{
			var bgColor:uint;
			var bgAlpha:Number;
			var textColor:uint;
			
			if (state == "normal")
			{
				textColor = _textNormalColor;
				if (_evenIndex)
				{
					bgColor = _bgColor1;
					bgAlpha = _bgAlpha1;
				}
				else
				{
					bgColor = _bgColor2;
					bgAlpha = _bgAlpha2;
				}
			}
			else if (state == "selected")
			{
				textColor = _textSelectedColor;
				bgColor = _bgSelectedColor;
				bgAlpha = _bgSelectedAlpha;
			}
			
			labelField.width = (_itemWidth / 2) - 5;
			inputField.width = (_itemWidth / 2) - 5;
			inputField.x = (_itemWidth / 2) + 5;
			labelField.textColor = textColor;
			inputField.textColor = textColor;
			
			background.graphics.clear();
			background.graphics.beginFill(bgColor, bgAlpha);
			background.graphics.drawRect(0, 0, _itemWidth, _itemHeight);
			background.graphics.endFill();
			
			propertyBrowseButton.x = _itemWidth - propertyBrowseButton.width;
			propertyBrowseButton.y = (_itemHeight - propertyBrowseButton.height) / 2;
			propertyBrowseButton.visible = _browse;
		}
		
		private function handleStateChange(e:Event):void 
		{
			if (state == "selected")
			{
				stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyPress, false, 2, true);
			}
			else
			{
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyPress);
			}
		}
		
		private function handleKeyPress(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{				
				if (stage.focus == inputField)
				{
					stage.focus = this;
				}
				else
				{
					stage.focus = inputField;
					inputField.setSelection(0, inputField.text.length);
				}
			}
			else if (e.keyCode == Keyboard.ESCAPE)
			{
				if (stage.focus == inputField)
				{
					inputField.text = _previousValue;
					stage.focus = this;
				}
			}
			
			if (stage.focus == inputField && e.keyCode)
			{
				e.stopImmediatePropagation();
			}
		}
		
		private function handleInputFieldFocus(e:FocusEvent):void 
		{
			_previousValue = value;
		}
		
		private function handleInputFieldBlur(e:FocusEvent):void 
		{
			if (_previousValue != value)
				dispatchEvent(new Event("changeProperty"));
		}
		
		private function handlePropertyBrowseClick(e:MouseEvent):void 
		{
			dispatchEvent(new Event("browse"));
		}
	}

}