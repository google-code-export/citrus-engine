package services 
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import model.vo.ObjectAsset;
	import model.vo.ObjectAssetParam;
	public class AssetParamParser implements IAssetParamParser
	{
		private var _assets:Vector.<ObjectAsset>;
		
		public function makeAssetsFromDirectory(rootDirectory:File):Vector.<ObjectAsset>
		{
			var asFiles:Array = new Array();
			findASFileInDirectory(rootDirectory, asFiles);
			
			_assets = new Vector.<ObjectAsset>();
			
			var stream:FileStream;
			var assetName:String;
			var assetSuperClassName:String;
			var regex:RegExp;
			var regexResult:Object;
			var params:Vector.<ObjectAssetParam>;
			for each (var asFile:File in asFiles)
			{
				stream = new FileStream();
				stream.open(asFile, FileMode.READ);
				var contents:String = stream.readUTFBytes(stream.bytesAvailable);
				
				params = new Vector.<ObjectAssetParam>();
				
				//Extracts the variable name and type from all public variable declarations that are prefixed with [Property]
				regex = /\[Property(?:\(\s*([^)]+)\))?][\s]*public var (\w+)\s*:\s*(\w+|\*)./gs;
				findParamsInFile(regex, asFile, contents, params);
				
				//Extracts the setter name and type from all public setter declarations that are prefixed with [Property]
				regex = /\[Property(?:\(\s*([^)]+)\))?][\s]*(?:override )?public (?:override )?function set (\w+)\(\s*\w*\s*:\s*(\w*|\*)\s*\)/gs;
				findParamsInFile(regex, asFile, contents, params);
				
				//If it gets in here, it has [Property] meta tags.
				if (params.length > 0)
				{
					//Get the package name
					var className:String = asFile.name.substring(0, asFile.name.length - 3);
					className = getQualifiedClassName(className, contents);
						
					//Get the superclass name
					assetSuperClassName = getQualifiedSuperClassName(contents);
					
					//TODO Parse the package name out of the class name for readability in-app
					//TOOD Get the superClass package name
					_assets.push(new ObjectAsset(className, assetSuperClassName, params));
				}
			}
			
			//Look at each asset whose superclass doesn't have a qualified classpath and qualify it.
			for each (var asset:ObjectAsset in _assets)
			{
				//If there is no period, then it's not qualified, (or is in the root)
				var packageName:String = asset.getSuperClassPackageName();
				if (packageName == "")
				{
					//Look for a class with a package that is the same as this asset's package. If found, use that.
					var superClass:ObjectAsset = getAssetByClassName(asset.getPackageName() + "." + asset.superClassName);
					if (superClass)
						asset.superClassName = superClass.className;
					
					//NOTE There is a possibility if someone has two classes with the same name that the wrong superclass will be chosen.
				}
			}
			
			//Attach the superClass's params to each asset.
			for each (asset in _assets)
			{
				var parentAsset:ObjectAsset = getAssetByName(asset.superClassName);
				if (parentAsset)
					copyParamsIntoAsset(parentAsset, asset);
			}
			
			return _assets;
		}
		
		private function getQualifiedClassName(className:String, contents:String):String
		{
			var getPackageNameRegex:RegExp = /package ([\w\.]*)/;
			var getPackageNameResult:Object = getPackageNameRegex.exec(contents);
			if (getPackageNameResult && getPackageNameResult[1])
				className = getPackageNameResult[1] + "." + className;
			
			return className;
		}
		
		private function getQualifiedSuperClassName(contents:String):String
		{
			var superClassName:String;
			var getSuperClassNameRegex:RegExp = /public class (?:\w+) extends (\w+)/;
			var superClassNameResult:Object = getSuperClassNameRegex.exec(contents);
			if (superClassNameResult)
			{
				superClassName = superClassNameResult[1];
				var getSuperClassPackageRegex:RegExp = /import [^;\s]+/gs; //go through each import and check to see if it is the superclass;
				do
				{
					var superClassPackageResult:Object = getSuperClassPackageRegex.exec(contents);
					if (superClassPackageResult)
					{
						var isPackageRegExp:RegExp = new RegExp(superClassName);
						var isPackageResult:Object = isPackageRegExp.exec(superClassPackageResult[0]);
						
						//If it gets in here, this means it's the correct import
						if (isPackageResult)
							superClassName = String(superClassPackageResult).substr(7); //cut off the "import " part;
					}
				}
				while (superClassPackageResult);
			}
			else
			{
				superClassName = "";
			}
			
			return superClassName;
		}
		
		private function findASFileInDirectory(dir:File, putInArray:Array):void
		{
			if (!dir.exists)
				return;
				
			var files:Array = dir.getDirectoryListing();
			var currFile:File;
			for (var i:uint = 0; i < files.length; i++)
			{
				currFile = files[i];
				if (currFile.extension == "as")
				{
					putInArray.push(currFile);
				}
				else if (currFile.isDirectory)
				{
					findASFileInDirectory(currFile, putInArray);
				}
			}
		}
		
		private function findParamsInFile(regex:RegExp, file:File, contents:String, params:Vector.<ObjectAssetParam>):void
		{
			do
			{
				var regexResult:Object = regex.exec(contents);
				if (regexResult)
				{
					//If there are meta options, parse them out
					if (regexResult[1])
					{
						var options:Object = {};
						//Parse through the key/value pairs in the meta options
						var getKeyValues:RegExp = /(\w+)\s*=\s*"([^"]*)"\s*(,)?\s*/gs;
						do
						{
							var getKeyValuesResult:Object = getKeyValues.exec(regexResult[1]);
							if (getKeyValuesResult)
							{
								options[getKeyValuesResult[1]] = getKeyValuesResult[2];
							}
						}
						while (getKeyValuesResult && getKeyValuesResult[3] == ",");
					}
					params.push(new ObjectAssetParam(regexResult[2], regexResult[3], false, options));
				}
			}
			while (regexResult != null);
		}
		
		private function getAssetByName(name:String):ObjectAsset
		{
			for each (var asset:ObjectAsset in _assets)
			{
				if (asset.className == name)
					return asset;
			}
			return null;
		}
		
		private function copyParamsIntoAsset(parentAsset:ObjectAsset, asset:ObjectAsset):void
		{
			for (var i:int = 0; i < parentAsset.params.length; i++) 
			{
				var originalParam:ObjectAssetParam = parentAsset.params[i];
				var overriddenParam:ObjectAssetParam = asset.getParamByName(originalParam.name);
				//Ensure we don't copy in params that have overridden serialized versions.
				if (!overriddenParam)
				{
					var item:ObjectAssetParam = new ObjectAssetParam(originalParam.name, originalParam.type, true, originalParam.options);
					asset.params.push(item);
				}
			}
			
			var grandparentAsset:ObjectAsset = getAssetByName(parentAsset.superClassName);
			if (grandparentAsset)
			{
				copyParamsIntoAsset(grandparentAsset, asset);
			}
		}
		
		private function getAssetByClassName(qualifiedClassName:String):ObjectAsset
		{
			for each (var asset:ObjectAsset in _assets)
			{
				if (asset.className == qualifiedClassName)
					return asset;
			}
			return null;
		}
	}

}