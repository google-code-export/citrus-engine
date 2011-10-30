package events 
{
	import com.codeazur.fzip.FZip;
	import flash.events.Event;
	
	public class CodeDownloadEvent extends Event 
	{
		public static const CODE_DOWNLOAD_PROGRESS:String = "codeDownloadProgress";
		public static const CODE_DOWNLOAD_COMPLETE:String = "codeDownloadComplete";
		public static const CODE_DOWNLOAD_ERROR:String = "codeDownloadError";
		public static const CODE_PARSE_ERROR:String = "codeParseError";
		
		public var data:Object;
		
		public function CodeDownloadEvent(type:String, data:Object) 
		{
			super(type, false, false);
			this.data = data;
		}
		
		override public function clone():Event
		{
			return new CodeDownloadEvent(type, data);
		}
		
	}

}