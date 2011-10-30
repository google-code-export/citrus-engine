package model.vo 
{
	public class ObjectInstanceParam
	{
		public var name:String;
		public var type:String;
		public var inherited:Boolean;
		public var options:Object = {};
		
		public function ObjectInstanceParam(name:String, type:String, inherited:Boolean, options:Object) 
		{
			this.name = name;
			this.type = type;
			this.inherited = inherited;
			
			//copy the options object to ensure it's not tied to the options object of another param
			for (var a:String in options)
				this.options[a] = options[a];
		}
		
		public function copy():ObjectInstanceParam
		{
			var instanceParamCopy:ObjectInstanceParam = new ObjectInstanceParam(name, type, inherited, options);
			return instanceParamCopy;
		}
		
		public function getReadableName():String
		{
			var regex:RegExp = /(\w)/;
			var readableName:String = name.replace(regex, makeFirstLetterUppercase);
			regex = /([a-z])([A-Z0-9])/g;
			readableName = readableName.replace(regex, insertSpaceBetweenWords);
			return readableName;
		}
		
		public function get value():Object
		{
			if (options.value != null && options.value != "")
				return options.value;
			else
			{
				if (options.value == "")
					return "";
				else if (options.value == 0)
					return 0;
				else
					return undefined;
			}
		}
		
		public function set value(v:Object):void
		{
			options.value = v;
		}
		
		public function toString():String
		{
			return name + ":" + type;
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