package events 
{
	import components.MapObjectInstance;
	import flash.events.Event;
	
	public class MapObjectEvent extends Event 
	{
		public static const MAP_GRAPHIC_LOADED:String = "mapGraphicLoaded";
		
		public var mapObject:MapObjectInstance;
		
		public function MapObjectEvent(type:String, mapObject:MapObjectInstance) 
		{
			super(type, false, false);
			this.mapObject = mapObject;
		}
		
		override public function clone():Event
		{
			return new MapObjectEvent(type, mapObject);
		}
	}

}