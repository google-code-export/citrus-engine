package model 
{
	import events.AssetListUpdatedEvent;
	import flash.filesystem.File;
	import model.vo.ObjectAsset;
	import org.robotlegs.mvcs.Actor;
	import services.IAssetParamParser;
	
	public class AssetModel extends Actor
	{
		[Inject]
		public var assetParamParser:IAssetParamParser;
		
		[Inject]
		public var projectModel:ProjectModel;
		
		private var _assets:Vector.<ObjectAsset>;
		
		public function updateAssets():void
		{
			if (!projectModel.getProjectRootDirectory())
				return;
			
			_assets = assetParamParser.makeAssetsFromDirectory(projectModel.getProjectRootDirectory());
			dispatch(new AssetListUpdatedEvent());
		}
		
		public function get assets():Vector.<ObjectAsset>
		{
			return _assets;
		}
		
		public function getAssetByName(value:String):ObjectAsset
		{
			for each (var asset:ObjectAsset in _assets)
			{
				if (asset.className == value)
					return asset;
			}
			
			return null;
		}
	}

}