package mediators 
{
	import components.AssetList;
	import components.Map;
	import events.AssetListUpdatedEvent;
	import events.CreateObjectInstanceEvent;
	import flash.events.Event;
	import model.AssetModel;
	import model.vo.ObjectAsset;
	import org.robotlegs.mvcs.Mediator;
	
	public class AssetListMediator extends Mediator 
	{
		[Inject]
		public var view:AssetList;
		
		[Inject]
		public var assetModel:AssetModel;
		
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher, AssetListUpdatedEvent.ASSET_LIST_UPDATED, handleAssetListUpdated, AssetListUpdatedEvent);
			
			view.addEventListener("create", handleCreateInstance);
			
			updateAssetListView();
		}
		
		public function updateAssetListView():void
		{
			var listItems:Array = [];
			if (assetModel.assets && assetModel.assets.length > 0)
			{
				var n:Number = assetModel.assets.length;
				for (var i:int = 0; i < n; i++) 
				{
					var objectAsset:ObjectAsset = assetModel.assets[i];
					var listItem:Object = { };
					listItem.label = objectAsset.getUnqualifiedClassName();
					listItem.evenIndex = (i % 2 == 0);
					listItems.push(listItem);
					view.classField.text = "Drag to create an object.";
				}
			}
			else
			{
				view.classField.text = "No assets. Please create or open a project.";
			}
			view.list.items = listItems;
			view.list.update();
		}
		
		private function handleAssetListUpdated(e:AssetListUpdatedEvent):void 
		{
			updateAssetListView();
		}
		
		private function handleCreateInstance(e:Event):void 
		{
			var asset:ObjectAsset = assetModel.assets[view.draggingIndex];
			dispatch(new CreateObjectInstanceEvent(asset, view.placementPoint.x, view.placementPoint.y));
		}
	}

}