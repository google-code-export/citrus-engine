package commands 
{
	import flash.utils.Dictionary;
	import model.AssetModel;
	import model.vo.GameState;
	import model.vo.ObjectAsset;
	import model.vo.ObjectInstance;
	import org.robotlegs.mvcs.Command;
	
	public class VerifyObjectToAssetIntegrity extends Command 
	{
		[Inject]
		public var assetModel:AssetModel;
		
		[Inject]
		public var gameState:GameState;
		
		override public function execute():void
		{
			var associations:Dictionary = new Dictionary();
			var foundMissingAssets:Boolean = false;
			
			//Loop through all objects and see if they have matching assets.
			for each (var object:ObjectInstance in gameState.objects)
			{
				if (!associations[object.className] || associations[object.className] == "notfound")
				{
					var asset:ObjectAsset = assetModel.getAssetByName(object.className);
					if (!asset)
					{
						trace("There was a change to the known assets for this project, and the " + object.className + " is no longer a valid asset. All instances of this asset must be deleted. Do not save this level if this is unexpected.");
						associations[object.className] = "notfound";
						foundMissingAssets = true;
					}
					else
					{
						associations[object.className] = "found";
					}
				}
			}
			
			//Delete the objects that don't have assets
			if (foundMissingAssets)
			{
				for (var className:String in associations)
				{
					if (associations[className] == "notfound")
						gameState.deleteObjectsOfClass(className);
				}
			}
		}
	}

}