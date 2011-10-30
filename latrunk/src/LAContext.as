package  
{
	import commands.ClearCommandHistory;
	import commands.CopyObjectInstanceCommand;
	import commands.CreateNewLevelCommand;
	import commands.CreateObjectInstanceCommand;
	import commands.DeleteObjectInstanceCommand;
	import commands.OpenLevelCommand;
	import commands.SetupApplication;
	import commands.UpdateAssetDataCommand;
	import commands.UpdateLastOpenProjectPath;
	import commands.UpdateObjectPropertyCommand;
	import commands.VerifyObjectToAssetIntegrity;
	import components.AssetList;
	import components.Map;
	import components.PropertyInspector;
	import components.Sidebar;
	import events.AssetListUpdatedEvent;
	import events.CreateObjectInstanceEvent;
	import events.GameStateEvent;
	import events.ObjectInstanceEvent;
	import events.ProjectEvent;
	import events.UpdateObjectPropertyEvent;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import mediators.AssetListMediator;
	import mediators.LAMediator;
	import mediators.MapMediator;
	import mediators.PropertyInspectorMediator;
	import mediators.SidebarMediator;
	import model.ApplicationModel;
	import model.AssetModel;
	import model.ProjectModel;
	import model.vo.GameState;
	import org.robotlegs.mvcs.Context;
	import org.robotlegs.utilities.undoablecommand.CommandHistory;
	import org.robotlegs.utilities.undoablecommand.commands.StepBackwardCommand;
	import org.robotlegs.utilities.undoablecommand.commands.StepForwardCommand;
	import org.robotlegs.utilities.undoablecommand.HistoryEvent;
	import services.AssetParamParser;
	import services.IAssetParamParser;
	
	public class LAContext extends Context 
	{
		public function LAContext(contextView:DisplayObjectContainer) 
		{
			super(contextView, true);
		}
		
		override public function startup():void
		{
			//maps events
			commandMap.mapEvent("setup", SetupApplication);
			commandMap.mapEvent(ProjectEvent.PROJECT_ROOT_UPDATED, UpdateAssetDataCommand);
			commandMap.mapEvent(ProjectEvent.PROJECT_OPENED, CreateNewLevelCommand);
			commandMap.mapEvent(CreateObjectInstanceEvent.CREATE_OBJECT_INSTANCE, CreateObjectInstanceCommand, CreateObjectInstanceEvent);
			commandMap.mapEvent(UpdateObjectPropertyEvent.UPDATE_OBJECT_PROPERTY, UpdateObjectPropertyCommand, UpdateObjectPropertyEvent);
			commandMap.mapEvent(ObjectInstanceEvent.DELETE_OBJECT, DeleteObjectInstanceCommand, ObjectInstanceEvent);
			commandMap.mapEvent(ObjectInstanceEvent.COPY_OBJECT, CopyObjectInstanceCommand, ObjectInstanceEvent);
			commandMap.mapEvent(HistoryEvent.STEP_FORWARD, StepForwardCommand, HistoryEvent);
			commandMap.mapEvent(HistoryEvent.STEP_BACKWARD, StepBackwardCommand, HistoryEvent);
			commandMap.mapEvent(AssetListUpdatedEvent.ASSET_LIST_UPDATED, VerifyObjectToAssetIntegrity, AssetListUpdatedEvent);
			commandMap.mapEvent(ProjectEvent.PROJECT_ROOT_UPDATED, UpdateLastOpenProjectPath);
			commandMap.mapEvent(GameStateEvent.ALL_OBJECTS_CLEARED, ClearCommandHistory);
			commandMap.mapEvent(GameStateEvent.GAME_STATE_OPENED, ClearCommandHistory);
			commandMap.mapEvent(GameStateEvent.OPEN_GAME_STATE, OpenLevelCommand);
			
			//map services
			injector.mapSingletonOf(IAssetParamParser, AssetParamParser);
			
			//map models
			injector.mapSingleton(ProjectModel);
			injector.mapSingleton(AssetModel);
			injector.mapSingleton(GameState);
			injector.mapSingleton(CommandHistory);
			injector.mapSingleton(ApplicationModel);
			
			//map view
			mediatorMap.mapView(Map, MapMediator);
			mediatorMap.mapView(Sidebar, SidebarMediator);
			mediatorMap.mapView(PropertyInspector, PropertyInspectorMediator);
			mediatorMap.mapView(AssetList, AssetListMediator);
			
			mediatorMap.mapView(Main, LAMediator);
			
			dispatchEvent(new Event("setup"));
		}
	}

}