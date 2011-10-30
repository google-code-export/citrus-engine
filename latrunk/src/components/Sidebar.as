package components 
{
	import com.greensock.data.TweenMaxVars;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import adobe.utils.CustomActions;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import mx.controls.tabBarClasses.Tab;
	import spark.components.CheckBox;
	
	public class Sidebar extends Sprite 
	{
		[Embed(source = '../../lib/btn_collapse.png')] private var _btnCloseClass:Class;
		
		public var toggleButton:uint = Keyboard.S;
		public var openCloseButton:Sprite;
		public var map:Map;
		public var createTabButton:Sprite;
		public var propertiesTabButton:Sprite;
		
		private var _open:Boolean = true;
		private var _sidebarWidth:Number = 325;
		private var _contents:Dictionary = new Dictionary();
		private var _tabs:Dictionary = new Dictionary();
		private var _currTab:String;
		
		public function Sidebar(map:Map) 
		{
			this.map = map;
			
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			
			var closeBitmap:Bitmap = new _btnCloseClass();
			
			openCloseButton = new Sprite();
			addChild(openCloseButton);
			
			openCloseButton.buttonMode = true;
			openCloseButton.addChild(closeBitmap);
			openCloseButton.addEventListener(MouseEvent.CLICK, handleOpenCloseButtonClick);
		}
		
		public function get visibleContent():Sprite
		{
			if (!_currTab)
				return null;
			
			return _contents[_currTab];
		}
		
		public function open():void
		{
			if (_open)
				return;
				
			TweenMax.to(this, 0.4, { x: stage.stageWidth - _sidebarWidth } );
			_open = true;
			removeEventListener(MouseEvent.CLICK, openViaClick);
			openCloseButton.scaleX = 1;
			openCloseButton.x = 0;
			buttonMode = false;
		}
		
		public function close():void
		{
			if (!_open)
				return;
			
			TweenMax.to(this, 0.4, { x: stage.stageWidth - 50 } );
			_open = false;
			addEventListener(MouseEvent.CLICK, openViaClick);
			openCloseButton.scaleX = -1;
			openCloseButton.x = openCloseButton.width;
			buttonMode = true;
		}
		
		public function setContent(content:Sprite, tab:String):void
		{
			if (_contents[tab])
				removeChild(_contents[tab]);
			
			_contents[tab] = content;
			
			if (_contents[tab])
			{
				if (_currTab == null)
					_currTab = tab;
					
				var content:Sprite = _contents[tab];
				addChild(content);
				content.x = 12;
				content.y = 36;
				
				content.visible = (_currTab == tab);
				
				//Create tab button
				var tabButton:TabButton = new TabButton(tab);
				_tabs[tab] = tabButton;
				addChild(tabButton);
				tabButton.addEventListener(MouseEvent.CLICK, handleTabClick);
				
				//Position tab X
				var tabX:Number = openCloseButton.x + openCloseButton.width;
				for each (var currContent:Sprite in _contents)
				{
					tabX += tabButton.width + 5;
				}
				tabX -= tabButton.width;
				tabButton.x = tabX;
				tabButton.alpha = (_currTab == tab) ? 1 : .45;
			}
		}
		
		public function showTab(tab:String):void
		{
			if (_currTab == tab || !_contents[tab])
				return;
			
			if (visibleContent)
			{
				_tabs[_currTab].alpha = .45;
				visibleContent.visible = false;
			}
			
			_currTab = tab;
			
			visibleContent.visible = true;
			_tabs[_currTab].alpha = 1;
		}
		
		private function handleAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.addEventListener(Event.RESIZE, handleStageResize);
			
			draw();
		}
		
		private function handleKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == toggleButton)
			{
				if (_open)
					close();
				else
					open();
			}
		}
		
		private function handleStageResize(e:Event):void
		{
			draw();
		}
		
		private function openViaClick(e:MouseEvent):void 
		{
			open();
		}
		
		private function handleOpenCloseButtonClick(e:MouseEvent):void 
		{
			if (_open)
				close();
			else
				open();
			e.stopPropagation();
		}
		
		private function draw():void
		{
			var bgWidth:Number = 50;
			if (visibleContent)
				bgWidth += visibleContent.width;
			
			if (_open)
			{
				x = stage.stageWidth - _sidebarWidth;
			}
			else
			{
				x = stage.stageWidth - 50;
			}
			
			graphics.clear();
			graphics.beginFill(0, .6);
			graphics.drawRect(0, 24, _sidebarWidth, stage.stageHeight - y);
			graphics.endFill();
		}
		
		private function handleTabClick(e:MouseEvent):void 
		{
			showTab(e.target.name);
		}
	}

}