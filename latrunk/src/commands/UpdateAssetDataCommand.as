package commands 
{
	import model.AssetModel;
	import org.robotlegs.mvcs.Command;
	
	public class UpdateAssetDataCommand extends Command
	{
		[Inject]
		public var assetModel:AssetModel;
		
		override public function execute():void
		{
			assetModel.updateAssets();
		}
	}

}