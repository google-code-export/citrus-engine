package model.vo 
{
	
	public class ObjectInstance 
	{
		public var name:String;
		public var id:int;
		public var className:String;
		public var superClassName:String;
		public var params:Vector.<ObjectInstanceParam>;
		public var customSize:Boolean = false;
		
		public function ObjectInstance(newID:int, className:String, superClassName:String, params:Vector.<ObjectInstanceParam>, customSize:Boolean, name:String = null) 
		{
			id = newID;
			this.className = className;
			this.superClassName = superClassName;
			this.params = params;
			this.customSize = customSize;
			if (name)
				this.name = name;
			else
				this.name = getUnqualifiedClassName() + newID.toString();
		}
		
		public function copy(newID:int):ObjectInstance
		{
			var newParams:Vector.<ObjectInstanceParam> = new Vector.<ObjectInstanceParam>();
			for each (var instanceParam:ObjectInstanceParam in params)
			{
				newParams.push(instanceParam.copy());
			}
			return new ObjectInstance(newID, className, superClassName, newParams, customSize);
		}
		
		public function getParamByName(name:String):ObjectInstanceParam
		{
			for each (var param:ObjectInstanceParam in params)
			{
				if (param.name == name)
					return param;
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
	}

}