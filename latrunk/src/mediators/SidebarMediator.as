package mediators 
{
	import components.AssetList;
	import components.Map;
	import components.PropertyInspector;
	import components.Sidebar;
	import events.GameStateEvent;
	import events.ObjectInstanceEvent;
	import org.robotlegs.mvcs.Mediator;
	
	public class SidebarMediator extends Mediator 
	{
		[Inject]
		public var view:Sidebar;
		
		private var _propertyInspector:PropertyInspector;
		private var _assetList:AssetList;
		
		override public function onRegister():void
		{
			_assetList = new AssetList(view.map);
			view.setContent(_assetList, "Creation");
			
			_propertyInspector = new PropertyInspector();
			view.setContent(_propertyInspector, "Properties");
		}
	}

}