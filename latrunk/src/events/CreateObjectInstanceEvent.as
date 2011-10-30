package events
{
	import flash.events.Event;
	import model.vo.GameState;
	import model.vo.ObjectAsset;
	
	public class CreateObjectInstanceEvent extends Event
	{
		public static const CREATE_OBJECT_INSTANCE:String = "createObjectInstance";
		
		public var objectAsset:ObjectAsset;
		public var x:Number;
		public var y:Number;
		
		public function CreateObjectInstanceEvent(objectAsset:ObjectAsset, x:Number, y:Number) 
		{
			super(CREATE_OBJECT_INSTANCE, false, false);
			this.objectAsset = objectAsset;
			this.x = x;
			this.y = y;
		}
		
		override public function clone():Event
		{
			return new CreateObjectInstanceEvent(objectAsset, x, y);
		}
	}

}