package events
{
	import flash.events.Event;
	
	public class GameStateEvent extends Event
	{
		public static const OPEN_GAME_STATE:String = "openGameState";
		public static const GAME_STATE_CHANGED:String = "gameStateChanged";
		public static const GAME_STATE_CREATED:String = "gameStateCreated";
		public static const GAME_STATE_DELETED:String = "gameStateDeleted";
		public static const GAME_STATE_RENAMED:String = "gameStateRenamed";
		public static const GAME_STATE_SAVED:String = "gameStateSaved";
		public static const GAME_STATE_OPENED:String = "gameStateOpened";
		public static const ALL_OBJECTS_CLEARED:String = "allObjectsCleared";
		
		public function GameStateEvent(type:String) 
		{
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			return new GameStateEvent(type);
		}
	}

}