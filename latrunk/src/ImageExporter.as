package  
{
	import com.adobe.images.JPGEncoder;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public class ImageExporter 
	{		
		private var _blueprint:Sprite;
		private var _levelName:String;
		
		public function ImageExporter(blueprint:Sprite, levelName:String) 
		{
			_blueprint = blueprint;
			_levelName = levelName;
		}
		
		public function execute():void
		{
			//draw something at 0, 0 so the draw() function starts there.
			_blueprint.graphics.beginFill(0, 1);
			_blueprint.graphics.drawRect(0, 0, 1, 1);
			_blueprint.graphics.endFill();
			
			//total width and height of the level
			var total:Point = new Point(_blueprint.width, _blueprint.height);
			
			//number of tiles 2880 wide and high
			var horizontalSections:Number = Math.ceil(total.x / 2880);
			var verticalSections:Number = Math.ceil(total.y / 2880);
			
			//break up level into 2880x2880 bitmaps
			var bitmaps:Array = [];
			for (var i:int=0; i < verticalSections; i++)
			{
				for (var j:int=0; j < horizontalSections; j++)
				{
					var w:Number = 2880;
					var h:Number = 2880;
					
					if (j == horizontalSections - 1)
					{
						w = total.x % 2880;
					}
					
					if (i == verticalSections - 1)
					{
						h = total.y % 2880;
					}
					
					var bitmapData:BitmapData = new BitmapData(w, h, false, 0xFFFFFF);
					var m:Matrix = new Matrix();
					m.translate(j * -2880, i * -2880);
					bitmapData.draw(_blueprint, m);
					bitmaps.push(bitmapData);
				}
			}
			
			_blueprint.graphics.clear();
			var stream:FileStream = new FileStream();
			
			var file:File = File.desktopDirectory;
			file.browseForDirectory("Select a directory to export into...");
			file.addEventListener(Event.SELECT, function():void
			{
				//write all the bitmaps as jpegs to the desktop
				for (i=0; i< bitmaps.length; i++)
				{
					var bd:BitmapData = bitmaps[i] as BitmapData;
					var jpegEncoder:JPGEncoder = new JPGEncoder(60);
					var byteArray:ByteArray = jpegEncoder.encode(bd);
					
					var tempFile:File = file.clone();
					tempFile.nativePath = tempFile.nativePath + File.separator + _levelName + " " + i + ".jpg";
					stream.open(tempFile, FileMode.WRITE);
					stream.writeBytes(byteArray, 0, byteArray.length);
					stream.close();
				}
			
			});
		}
	}
	
}