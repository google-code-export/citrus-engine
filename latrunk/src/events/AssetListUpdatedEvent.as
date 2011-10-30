package events
{
	import flash.events.Event;
	
	public class AssetListUpdatedEvent extends Event
	{
		public static const ASSET_LIST_UPDATED:String = "assetListUpdated";
		
		public function AssetListUpdatedEvent() 
		{
			super(ASSET_LIST_UPDATED, false, false);
		}
		
		override public function clone():Event
		{
			return new AssetListUpdatedEvent();
		}
	}

}