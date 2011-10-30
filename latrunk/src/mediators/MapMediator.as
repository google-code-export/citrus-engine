package mediators 
{
	import com.greensock.events.TransformEvent;
	import com.greensock.transform.TransformItem;
	import components.Map;
	import components.MapObjectInstance;
	import components.TransformInstance;
	import events.GameStateEvent;
	import events.MapObjectEvent;
	import events.ObjectInstanceEvent;
	import events.ProjectEvent;
	import events.UpdateObjectPropertyEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import model.ApplicationModel;
	import model.ProjectModel;
	import model.vo.GameState;
	import model.vo.ObjectInstance;
	import model.vo.ObjectInstanceParam;
	import model.vo.PropertyUpdateVO;
	import org.robotlegs.mvcs.Mediator;
	
	public class MapMediator extends Mediator
	{
		[Inject]
		public var view:Map;
		
		[Inject]
		public var gameState:GameState;
		
		[Inject]
		public var projectModel:ProjectModel;
		
		[Inject]
		public var applicationModel:ApplicationModel;
		
		override public function onRegister():void 
		{
			eventMap.mapListener(eventDispatcher, ObjectInstanceEvent.OBJECT_CREATED, handleObjectCreated, ObjectInstanceEvent);
			eventMap.mapListener(eventDispatcher, ObjectInstanceEvent.OBJECT_SELECTED, handleObjectSelected, ObjectInstanceEvent);
			eventMap.mapListener(eventDispatcher, ObjectInstanceEvent.OBJECT_DELETED, handleObjectDeleted, ObjectInstanceEvent);
			eventMap.mapListener(eventDispatcher, UpdateObjectPropertyEvent.OBJECT_PROPERTY_UPDATED, handleObjectPropertyUpdated, UpdateObjectPropertyEvent);
			eventMap.mapListener(eventDispatcher, ProjectEvent.SWF_PATH_UPDATED, handleSWFPathUpdated);
			eventMap.mapListener(eventDispatcher, ProjectEvent.PROJECT_ROOT_UPDATED, handleProjectRootUpdated);
			eventMap.mapListener(eventDispatcher, GameStateEvent.ALL_OBJECTS_CLEARED, handleAllObjectsCleared);
			
			view.addEventListener(MapObjectEvent.MAP_GRAPHIC_LOADED, handleMapGraphicLoaded);
			
			updateImageRoot();
		}
		
		private function handleObjectCreated(e:ObjectInstanceEvent):void
		{
			var objectInstance:ObjectInstance = e.objectInstance;
			
			//set all data params on visual object
			var mapObject:MapObjectInstance = view.createMapObject(objectInstance.id);
			for each (var param:ObjectInstanceParam in objectInstance.params)
			{
				if (mapObject.hasOwnProperty(param.name))
				{
					mapObject[param.name] = param.value;
				}
			}
			
			//listen for transform updates so we can update the data
			mapObject.transformItem.addEventListener(TransformEvent.SELECT, handleMapObjectSelect);
			mapObject.transformItem.addEventListener(TransformEvent.DESELECT, handleMapObjectDeselect);
			mapObject.transformItem.addEventListener(TransformEvent.FINISH_INTERACTIVE_SCALE, handleMapObjectScale);
			mapObject.transformItem.addEventListener(TransformEvent.FINISH_INTERACTIVE_MOVE, handleMapObjectMove);
			mapObject.transformItem.addEventListener(TransformEvent.FINISH_INTERACTIVE_ROTATE, handleMapObjectRotate);
			mapObject.transformItem.addEventListener(TransformEvent.DELETE, handleMapObjectDelete);
		}
		
		private function handleObjectSelected(e:ObjectInstanceEvent):void 
		{
			if (!e.objectInstance) //Happens when something is deselected.
			{
				view.tm.deselectAll();
				return;
			}
				
			var mapObject:MapObjectInstance = view.getMapObjectByID(e.objectInstance.id);
			if (mapObject)
				mapObject.transformItem.selected = true;
		}
		
		private function handleObjectDeleted(e:ObjectInstanceEvent):void 
		{
			var mapObject:MapObjectInstance = view.getMapObjectByID(e.objectInstance.id);
			view.deleteMapObject(mapObject);
		}
		
		private function handleObjectPropertyUpdated(e:UpdateObjectPropertyEvent):void 
		{
			//Loop through each property update and apply it to the visual object
			for (var i:int = 0; i < e.updates.length; i++) 
			{
				var updateVO:PropertyUpdateVO = e.updates[i];
				var mapObject:MapObjectInstance = view.getMapObjectByID(updateVO.objectInstance.id);
				var param:ObjectInstanceParam = updateVO.objectInstance.getParamByName(updateVO.property);
				
				if (mapObject.hasOwnProperty(param.name))
					mapObject[param.name] = param.value;
			}
		}
		
		private function handleMapObjectSelect(e:TransformEvent):void 
		{
			var transformInstance:TransformInstance = TransformItem(e.target).targetObject as TransformInstance;
			var dataObject:ObjectInstance = gameState.getObjectByID(transformInstance.id);
			gameState.selectedObject = dataObject;
		}
		
		private function handleMapObjectDeselect(e:TransformEvent):void 
		{
			gameState.selectedObject = null;
		}
		
		private function handleMapObjectScale(e:TransformEvent):void 
		{
			var transformInstance:TransformInstance = TransformItem(e.target).targetObject as TransformInstance;
			var dataObject:ObjectInstance = gameState.getObjectByID(transformInstance.id);
			
			var updates:Array = new Array();
			updates.push(new PropertyUpdateVO(dataObject, "x", transformInstance.x));
			updates.push(new PropertyUpdateVO(dataObject, "y", transformInstance.y));
			updates.push(new PropertyUpdateVO(dataObject, "width", transformInstance.unrotatedWidth));
			updates.push(new PropertyUpdateVO(dataObject, "height", transformInstance.unrotatedHeight));
			
			dispatch(new UpdateObjectPropertyEvent(UpdateObjectPropertyEvent.UPDATE_OBJECT_PROPERTY, updates));
			
			//if width and height
			var view:String = dataObject.getParamByName("view").value as String;
			if (view && view.length > 0)
			{
				dataObject.customSize = true;
			}
		}
		
		private function handleMapObjectMove(e:TransformEvent):void 
		{
			var transformInstance:TransformInstance = TransformItem(e.target).targetObject as TransformInstance;
			var dataObject:ObjectInstance = gameState.getObjectByID(transformInstance.id);
			
			var updates:Array = new Array();
			updates.push(new PropertyUpdateVO(dataObject, "x", transformInstance.x));
			updates.push(new PropertyUpdateVO(dataObject, "y", transformInstance.y));
			
			dispatch(new UpdateObjectPropertyEvent(UpdateObjectPropertyEvent.UPDATE_OBJECT_PROPERTY, updates));
		}
		
		private function handleMapObjectRotate(e:TransformEvent):void 
		{
			var transformInstance:TransformInstance = TransformItem(e.target).targetObject as TransformInstance;
			var dataObject:ObjectInstance = gameState.getObjectByID(transformInstance.id);
			
			var updates:Array = new Array();
			updates.push(new PropertyUpdateVO(dataObject, "x", transformInstance.x));
			updates.push(new PropertyUpdateVO(dataObject, "y", transformInstance.y));
			updates.push(new PropertyUpdateVO(dataObject, "rotation", transformInstance.rotation));
			
			dispatch(new UpdateObjectPropertyEvent(UpdateObjectPropertyEvent.UPDATE_OBJECT_PROPERTY, updates));
		}
		
		private function handleMapObjectDelete(e:TransformEvent):void 
		{
			var transformInstance:TransformInstance = TransformItem(e.target).targetObject as TransformInstance;
			var dataObject:ObjectInstance = gameState.getObjectByID(transformInstance.id);
			
			dispatch(new ObjectInstanceEvent(ObjectInstanceEvent.DELETE_OBJECT, dataObject));
		}
		
		private function handleSWFPathUpdated(e:Event):void 
		{
			updateImageRoot();
		}
		
		private function updateImageRoot():void
		{
			if (projectModel.getSWFFile())
				view.imageRoot = projectModel.getSWFFile().parent;
			else
				view.imageRoot = null;
		}
		
		private function handleProjectRootUpdated(e:Event):void 
		{
			updateImageRoot();
		}
		
		private function handleAllObjectsCleared(e:Event):void 
		{
			view.clearAllObjects();
			view.moveMapTo(0, 0);
		}
		
		private function handleMapGraphicLoaded(e:MapObjectEvent):void 
		{
			var objectInstance:ObjectInstance = gameState.getObjectByID(e.mapObject.id);
			
			if (!objectInstance.customSize && applicationModel.resizeBoundsToGraphic)
			{
				var updates:Array = [];
				updates.push(new PropertyUpdateVO(objectInstance, "width", e.mapObject.overlay.graphic.width));
				updates.push(new PropertyUpdateVO(objectInstance, "height", e.mapObject.overlay.graphic.height));
				dispatch(new UpdateObjectPropertyEvent(UpdateObjectPropertyEvent.UPDATE_OBJECT_PROPERTY, updates));
			}
		}
	}

}