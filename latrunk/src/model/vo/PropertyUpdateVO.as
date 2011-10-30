package model.vo 
{	
	public class PropertyUpdateVO
	{
		public var objectInstance:ObjectInstance;
		public var property:String;
		public var value:Object;
		
		public function PropertyUpdateVO(objectInstance:ObjectInstance, property:String, value:Object) 
		{
			this.objectInstance = objectInstance;
			this.property = property;
			this.value = value;
		}
		
	}

}