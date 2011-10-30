package model.vo
{
	public class ObjectAsset 
	{
		public var className:String;
		public var superClassName:String;
		public var params:Vector.<ObjectAssetParam> = new Vector.<ObjectAssetParam>();
		
		public function ObjectAsset(className:String, superClassName:String, params:Vector.<ObjectAssetParam>) 
		{
			this.className = className;
			this.superClassName = superClassName;
			this.params = params;
		}
		
		public function toString():String
		{
			var str:String = className + " : " + superClassName;
			for (var i:int = 0; i < params.length; i++) 
			{
				var item:ObjectAssetParam = params[i];
				str += "\n\t" + item.name + ":" + item.type;
			}
			return str;
		}
		
		public function getParamByName(name:String):ObjectAssetParam
		{
			for (var i:int = 0; i < params.length; i++)
			{
				if (params[i].name == name)
				{
					return params[i];
				}
			}
			return null;
		}
		
		public function getUnqualifiedClassName():String
		{
			var lastPeriodIndex:int = className.lastIndexOf(".");
			if (lastPeriodIndex == -1)
				return className;
				
			return className.substring(lastPeriodIndex + 1);
		}
		
		public function getPackageName():String
		{
			var lastPeriodIndex:int = className.lastIndexOf(".");
			if (lastPeriodIndex == -1)
				return "";
			
			return className.substring(0, lastPeriodIndex);
		}
		
		public function getSuperClassPackageName():String
		{
			var lastPeriodIndex:int = superClassName.lastIndexOf(".");
			if (lastPeriodIndex == -1)
				return "";
			
			return superClassName.substring(0, lastPeriodIndex);
		}
	}

}