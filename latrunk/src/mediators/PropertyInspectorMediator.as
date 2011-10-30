package mediators 
{
	import components.listitems.LAListItem;
	import components.listitems.PropertyListItem;
	import components.PropertyInspector;
	import events.ObjectInstanceEvent;
	import events.UpdateObjectPropertyEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import model.ProjectModel;
	import model.vo.GameState;
	import model.vo.ObjectInstanceParam;
	import model.vo.PropertyUpdateVO;
	import org.robotlegs.mvcs.Mediator;
	
	public class PropertyInspectorMediator extends Mediator 
	{
		[Inject]
		public var view:PropertyInspector;
		
		[Inject]
		public var gameState:GameState;
		
		[Inject]
		public var projectModel:ProjectModel;
		
		private var _itemToBrowseFor:Object;
		
		override public function onRegister():void
		{
			view.list.addEventListenerToButtons("changeProperty", changePropertyOnModel);
			view.list.addEventListenerToButtons("browse", handlePropertyBrowse);
			view.nameField.addEventListener(FocusEvent.FOCUS_OUT, handleNameFieldBlur);
			
			eventMap.mapListener(eventDispatcher, UpdateObjectPropertyEvent.OBJECT_PROPERTY_UPDATED, changePropertyOnView);
			eventMap.mapListener(eventDispatcher, ObjectInstanceEvent.OBJECT_SELECTED, handleObjectSelected, ObjectInstanceEvent);
		}
		
		private function changePropertyOnModel(e:Event):void
		{
			var selectedIndex:int = view.list.getIndexOfButton(e.target as PropertyListItem);
			var newValue:String = view.list.items[selectedIndex].value as String;
			
			var updates:Array = new Array();
			updates.push(new PropertyUpdateVO(gameState.selectedObject, gameState.selectedObject.params[selectedIndex].name, newValue));
			dispatch(new UpdateObjectPropertyEvent(UpdateObjectPropertyEvent.UPDATE_OBJECT_PROPERTY, updates));
		}
		
		private function handlePropertyBrowse(e:Event):void
		{
			var file:File = projectModel.getSWFFile();
			_itemToBrowseFor = view.list.getItemByButton(e.target as LAListItem);
			file.addEventListener(Event.SELECT, handlePropertyBrowseSelect);
			file.browseForOpen(_itemToBrowseFor.label + " for " + gameState.selectedObject.name + "...", [new FileFilter("Compatible Graphics", "*.jpg;*.gif;*.png;*.swf")]);
		}
		
		private function changePropertyOnView(e:UpdateObjectPropertyEvent):void 
		{
			if (e.updates[0] && e.updates[0].objectInstance != gameState.selectedObject)
				return;
				
			for (var i:int = 0; i < e.updates.length; i++)
			{
				var update:PropertyUpdateVO = e.updates[i];
				var param:ObjectInstanceParam = update.objectInstance.getParamByName(update.property);
				var index:int = update.objectInstance.params.indexOf(param);
				view.list.items[index].value = update.value.toString();
			}
			view.list.update();
		}
		
		private function handleNameFieldBlur(e:FocusEvent):void 
		{
			var newName:String = view.nameField.text;
			
			//See if the name changed
			if (gameState.selectedObject.name != newName)
			{
				gameState.renameObject(gameState.selectedObject, newName);
			}
		}
		
		private function handlePropertyBrowseSelect(e:Event):void 
		{
			var file:File = e.target as File;
			
			var selectedIndex:int = view.list.items.indexOf(_itemToBrowseFor);
			var newValue:String =  projectModel.getSWFFile().parent.getRelativePath(file, true);
			
			var updates:Array = new Array();
			updates.push(new PropertyUpdateVO(gameState.selectedObject, gameState.selectedObject.params[selectedIndex].name, newValue));
			dispatch(new UpdateObjectPropertyEvent(UpdateObjectPropertyEvent.UPDATE_OBJECT_PROPERTY, updates));
			
			_itemToBrowseFor = null;
		}
		
		private function handleObjectSelected(e:ObjectInstanceEvent):void 
		{
			if (gameState.selectedObject)
			{
				//Update header
				view.nameField.text = gameState.selectedObject.name;
				view.classField.text = gameState.selectedObject.className;
			
				//Update list
				var items:Array = new Array();
				var param:ObjectInstanceParam;
				var item:Object;
				for (var i:int = 0; i < gameState.selectedObject.params.length; i++)
				{
					param = gameState.selectedObject.params[i];
					item = { };
					item.inherited = param.inherited;
					item.label = param.getReadableName();
					item.value = param.value;
					item.evenIndex = (i % 2 == 0);
					item.state = "normal";
					item.browse = (param.options.browse == "true" && projectModel.getSWFFile() && projectModel.getSWFFile().exists);
					items.push(item);
				}
				view.list.items = items;
				view.nameField.visible = true;
			}
			else
			{
				view.nameField.text = "";
				view.classField.text = "";
				view.list.items = [];
				view.nameField.visible = false;
			}
		}
	}

}