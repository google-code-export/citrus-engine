package events 
{
	import flash.events.Event;
	
	public class ProjectEvent extends Event
	{
		public static const PROJECT_CREATED:String = "projectCreated";
		public static const PROJECT_SAVED:String = "projectSaved";
		public static const PROJECT_OPENED:String = "projectOpened";
		public static const PROJECT_ROOT_UPDATED:String = "projectRootUpdated";
		public static const SWF_PATH_UPDATED:String = "swfPathUpdated";
		public static const SWF_PATH_BROKEN:String = "swfPathBroken";
		
		public function ProjectEvent(type:String) 
		{
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			return new ProjectEvent(type);
		}
	}

}