package services 
{
	import flash.filesystem.File;
	import model.vo.ObjectAsset;
	
	public interface IAssetParamParser 
	{
		function makeAssetsFromDirectory(directory:File):Vector.<ObjectAsset>;
	}
	
}