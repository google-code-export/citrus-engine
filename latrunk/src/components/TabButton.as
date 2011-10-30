package components 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class TabButton extends Sprite 
	{
		[Embed(source = '../../lib/btn_tab.png')] private var _btnTabClass:Class;
		
		public function TabButton(name:String) 
		{
			this.name = name;
			
			var tabBitmap:Bitmap = new _btnTabClass();
			buttonMode = true;
			addChild(tabBitmap);
			var tf:TextFormat = new TextFormat("_sans", 14, 0xffffff, true);
			var tabTextField:TextField = new TextField();
			addChild(tabTextField);
			tabTextField.selectable = false;
			tabTextField.defaultTextFormat = tf;
			tabTextField.tabEnabled = false;
			tabTextField.mouseEnabled = false;
			tabTextField.text = name;
			tabTextField.y = 2;
			tabTextField.width = tabBitmap.width;
			tabTextField.autoSize = "center";
		}
		
	}

}