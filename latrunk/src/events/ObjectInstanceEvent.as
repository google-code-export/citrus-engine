package events 
{
	import flash.events.Event;
	import model.vo.ObjectInstance;
	
	public class ObjectInstanceEvent extends Event
	{
		public static const DELETE_OBJECT:String = "deleteObject";
		public static const COPY_OBJECT:String = "copyObject";
		
		public static const OBJECT_CREATED:String = "objectCreated";
		public static const OBJECT_DELETED:String = "objectDeleted";
		public static const OBJECT_SELECTED:String = "objectSelected";
		public static const OBJECT_RENAMED:String = "objectRenamed";
		public static const ADDED_TO_CLIPBOARD:String = "addedToClipboard";
		
		public var objectInstance:ObjectInstance;
		
		public function ObjectInstanceEvent(type:String, objectInstance:ObjectInstance) 
		{
			super(type, false, false);
			this.objectInstance = objectInstance;
		}
		
		override public function clone():Event
		{
			return new ObjectInstanceEvent(type, objectInstance);
		}
	}

}