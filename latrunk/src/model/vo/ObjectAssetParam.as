package model.vo
{
	public class ObjectAssetParam
	{
		public var name:String;
		public var type:String;
		public var inherited:Boolean = false;
		public var options:Object;
		
		public function ObjectAssetParam(name:String, type:String, inherited:Boolean, options:Object) 
		{
			this.name = name;
			this.type = type;
			this.inherited = inherited;
			this.options = options;
		}
		
		public function getReadableName():String
		{
			var regex:RegExp = /(\w)/;
			var readableName:String = name.replace(regex, makeFirstLetterUppercase);
			regex = /([a-z])([A-Z0-9])/g;
			readableName = readableName.replace(regex, insertSpaceBetweenWords);
			return readableName;
		}
		
		public function toString():String
		{
			return name + ":" + type;
		}
		
		public function get value():Object
		{
			if (options.value != undefined && options.value != "")
				return options.value;
			else
				return undefined;
		}
		
		public function set value(v:Object):void
		{
			options.value = v;
		}
		
		private function makeFirstLetterUppercase():String
		{
			return arguments[1].toUpperCase();
		}
		
		private function insertSpaceBetweenWords():String
		{
			return arguments[1] + " " + arguments[2];
		}
	}

}