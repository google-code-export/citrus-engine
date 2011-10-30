package components 
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class TestPopUp extends PopUp
	{
		public var text:TextField;
		public var titleField:TextField;
		
		public function TestPopUp(title:String, message:String, width:Number, height:Number, yesNo:Boolean) 
		{
			content = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(width, height, Math.PI / 2);
			content.graphics.beginGradientFill(GradientType.LINEAR, [0xeaeaea, 0xd4d4d4], [1, 1], [0, 255], m);
			content.graphics.drawRoundRect(0, 0, width, height, 2, 2);
			content.graphics.endFill();
			
			var textFormat:TextFormat = new TextFormat("_sans", 24, 0x565656, true);
			titleField = new TextField();
			titleField.width = width - 50;
			content.addChild(titleField);
			titleField.defaultTextFormat = textFormat;
			titleField.x = 12;
			titleField.y = 12;
			titleField.text = title;
			
			textFormat = new TextFormat("_sans", 14, 0x565656);
			text = new TextField();
			text.width = width - 50;
			text.height = height - 50;
			content.addChild(text);
			text.defaultTextFormat = textFormat;
			text.multiline = true;
			text.wordWrap = true;
			text.selectable = false;
			text.x = 12;
			text.y = 50;
			text.text = message;
			
			super(content, yesNo);
			
		}
		
	}

}