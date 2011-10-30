package components 
{
	import adobe.utils.CustomActions;
	import com.adobe.utils.IntUtil;
	import components.listitems.LAListItem;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	public class LAList extends Sprite
	{
		private var _numVisibleItems:uint;
		private var _topVisibleIndex:uint = 0;
		private var _listItemClass:Class;
		private var _items:Array = new Array();
		private var _selectedIndex:int = -1;
		private var _previousSelectedIndex:int = -1;
		private var _eventListeners:Array = [];
		private var _buttonsHaveListeners:Boolean;
		
		public function LAList(numVisibleItems:uint, listItemClass:Class) 
		{
			_listItemClass = listItemClass;
			this.numVisibleItems = numVisibleItems;
			
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false, 0, true);
			addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
		}
		
		private function handleAddedToStage(e:Event):void 
		{
			stage.addEventListener(Event.RENDER, handleRender, false, 1);
			stage.addEventListener(MouseEvent.CLICK, handleStageClick, true);
			stage.invalidate();
		}
		
		private function handleRemovedFromStage(e:Event):void 
		{
			stage.removeEventListener(Event.RENDER, handleRender);
			stage.removeEventListener(MouseEvent.CLICK, handleStageClick, true);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false);
		}
		
		public function get items():Array
		{
			return _items;
		}
		
		public function set items(value:Array):void
		{
			_items = value;
			
			if (_items.length < _numVisibleItems)
				_topVisibleIndex = 0;
			
			update();
		}
		
		public function get numVisibleItems():int
		{
			return _numVisibleItems;
		}
		
		public function set numVisibleItems(value:int):void
		{
			if (_numVisibleItems == value)
				return;
				
			_numVisibleItems = value;
			
			var i:int;
			//remove all children
			var n:Number = numChildren - 1;
			for (i = n; i >= 0; i--)
				removeChildAt(i);
			
			//add the appropriate amount back
			var nextY:Number = 0;
			for (i = 0; i < _numVisibleItems; i++) 
			{
				var item:LAListItem = new _listItemClass() as LAListItem;
				item.addEventListener(MouseEvent.MOUSE_DOWN, handleItemPress);
				addChild(item);
				item.y = nextY;
				item.visible = false;
				nextY += item.height;
			}
			
			//add listeners to buttons
			_buttonsHaveListeners = false;
			addButtonEventListeners();
			update();
		}
		
		public function get selectedIndex():int 
		{
			return _selectedIndex;
		}
		
		public function get selectedItem():Object
		{
			return items[_selectedIndex];
		}
		
		public function getButtonAt(index:Number):LAListItem
		{
			return getChildAt(index - _topVisibleIndex) as LAListItem;
		}
		
		public function getButtonByData(object:Object):LAListItem
		{
			return getButtonAt(items.indexOf(object)) as LAListItem;
		}
		
		public function getItemByButton(button:LAListItem):Object
		{
			var buttonIndex:int = getChildIndex(button);
			return items[_topVisibleIndex + buttonIndex];
		}
		
		public function getIndexOfButton(button:LAListItem):int
		{
			var buttonIndex:int = getChildIndex(button);
			
			if (buttonIndex == -1)
				return -1;
				
			return buttonIndex + _topVisibleIndex;
		}
		
		public function update():void
		{
			if (stage)
				stage.invalidate();
		}
		
		public function addEventListenerToButtons(type:String, listener:Function):void
		{
			for each (var object:Object in _eventListeners)
			{
				if (object.type == type && object.listener == listener)
					return;
			}
			removeButtonEventListeners();
			_eventListeners.push( { type: type, listener: listener } );
			addButtonEventListeners();
		}
		
		public function selectIndex(index:int):void
		{
			if (_selectedIndex == index)
				return;
				
			if (_selectedIndex != -1 && _items[_selectedIndex])
				items[_selectedIndex].state = "normal";
			_selectedIndex = index;
			if (_selectedIndex != -1 && _items[_selectedIndex])
			{
				stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 1);
				items[_selectedIndex].state = "selected";
			}
			else
			{
				_selectedIndex = -1;
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false);
			}
			
			//Change the scroll position if the selected index is out of view.
			if (_selectedIndex > -1)
			{
				if (_topVisibleIndex > _selectedIndex)
					_topVisibleIndex = _selectedIndex;
				else if (_topVisibleIndex + _numVisibleItems <= _selectedIndex)
					_topVisibleIndex = _selectedIndex - _numVisibleItems + 1;
			}
				
			update();
		}
		
		public function scroll(index:int):void
		{
			//constrain scrolling, then update
			var highestTopVisibleIndex:int = Math.max(_items.length - _numVisibleItems, 0);
			if (index < 0)
				_topVisibleIndex = 0;
			else if (index > highestTopVisibleIndex)
				_topVisibleIndex = highestTopVisibleIndex;
			else
				_topVisibleIndex = index;
				
			update();
		}
		
		private function handleRender(e:Event):void 
		{
			var listItem:LAListItem;
			var n:int = Math.min(items.length, _topVisibleIndex + _numVisibleItems);
			for (var i:int = _topVisibleIndex; i < n; i++)
			{
				var dataItem:Object = _items[i];
				listItem = getButtonAt(i);
				listItem.visible = true;
				for (var property:String in dataItem)
				{
					if (listItem.hasOwnProperty(property))
					{
						listItem[property] = dataItem[property];
					}
				}
				listItem.update();
			}
			
			var m:Number = _topVisibleIndex + _numVisibleItems;
			for (i = n; i < m; i++)
			{
				listItem = getButtonAt(i);
				listItem.visible = false;
			}
		}
		
		private function handleItemPress(e:MouseEvent):void 
		{
			var item:Object = getItemByButton(LAListItem(e.currentTarget));
			selectIndex(items.indexOf(item));
		}
		
		private function handleStageClick(e:MouseEvent):void 
		{
			if (!this.getBounds(stage).containsPoint(new Point(stage.mouseX, stage.mouseY)))
			{
				selectIndex( -1);
			}
		}
		
		private function handleKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.DOWN || (e.keyCode == Keyboard.TAB && !e.shiftKey))
			{
				selectIndex(_selectedIndex + 1);
				e.stopImmediatePropagation();
			}
			else if (e.keyCode == Keyboard.UP || (e.keyCode == Keyboard.TAB && e.shiftKey))
			{
				selectIndex(_selectedIndex - 1);
				e.stopImmediatePropagation();
			}
		}
		
		private function handleMouseWheel(e:MouseEvent):void 
		{
			if (e.delta < 0)
				scroll(_topVisibleIndex + 1);
			else
				scroll(_topVisibleIndex - 1);
		}
		
		private function addButtonEventListeners():void 
		{
			if (_buttonsHaveListeners)
				return;
				
			for (var i:int = 0; i < numChildren; i++) 
			{
				var item:LAListItem = getChildAt(i) as LAListItem;
				for (var j:int = 0; j < _eventListeners.length; j++)
					item.addEventListener(_eventListeners[j].type, _eventListeners[j].listener);
			}
			
			_buttonsHaveListeners = true;
		}
		
		private function removeButtonEventListeners():void
		{
			for (var i:int = 0; i < numChildren; i++) 
			{
				var item:LAListItem = getChildAt(i) as LAListItem;
				for (var j:int = 0; j < _eventListeners.length; j++)
					item.removeEventListener(_eventListeners[j].type, _eventListeners[j].listener);
			}
			
			_buttonsHaveListeners = false;
		}
	}

}