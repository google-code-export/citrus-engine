package events
{
	import flash.events.Event;
	import flash.filesystem.File;
	import model.vo.GameState;
	import model.vo.ObjectAsset;
	import model.vo.ObjectInstance;
	import model.vo.ObjectInstanceParam;
	
	public class UpdateObjectPropertyEvent extends Event
	{
		public static const UPDATE_OBJECT_PROPERTY:String = "updateObjectProperty";
		public static const OBJECT_PROPERTY_UPDATED:String = "objectPropertyUpdated";
		
		public var updates:Array;
		
		public function UpdateObjectPropertyEvent(type:String, updates:Array) 
		{
			super(type, false, false);
			this.updates = updates;
		}
		
		override public function clone():Event
		{
			return new UpdateObjectPropertyEvent(type, updates);
		}
	}

}