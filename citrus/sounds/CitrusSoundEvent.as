package citrus.sounds 
{

	import flash.events.Event;

	public class CitrusSoundEvent extends Event
	{
		public static const SOUND_ERROR:String = "SOUND_ERROR";
		public static const SOUND_COMPLETE:String = "SOUND_COMPLETE";
		public static const REPEAT_COMPLETE:String = "REPEAT_COMPLETE";
		public static const SOUND_LOADED:String = "SOUND_LOADED";
		public static const ALL_SOUNDS_LOADED:String = "ALL_SOUNDS_LOADED";
		
		public var soundName:String;
		public var timesToPlay:uint;
		public var repeatCount:uint;
		public var repeatLeft:uint;
		public var loadedRatio:Number;
		public var loaded:Boolean;
		public var error:Boolean;
		
		public function CitrusSoundEvent(type:String, sound:CitrusSound, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			super(type, bubbles, cancelable);
			
			soundName = sound.name;
			timesToPlay = sound.timesToPlay;
			repeatCount = sound.repeatCount;
			repeatLeft = timesToPlay - repeatCount;
			loadedRatio = sound.loadedRatio;
			loaded = sound.loaded;
			error = sound.ioerror;
		}
		
	}

}