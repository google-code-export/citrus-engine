package events 
{
	import flash.events.Event;
	
	public class SoftwareUpdateEvent extends Event
	{
		public static const NEW_VERSION_RESULT:String = "newVersionFound";
		public static const CHECK_VERSION_ERROR:String = "checkVersionError";
		public static const NEW_VERSION_DOWNLOADED:String = "newVersionDownloaded";
		
		public var newVersion:Boolean;
		public var version:String;
		public var downloadPath:String;
		
		public function SoftwareUpdateEvent(type:String, newVersion:Boolean, version:String, downloadPath:String) 
		{
			super(type, false, false);
			this.newVersion = newVersion;
			this.version = version;
			this.downloadPath = downloadPath;
		}
		
		override public function clone():Event
		{
			return new SoftwareUpdateEvent(type, newVersion, version, downloadPath);
		}
	}

}