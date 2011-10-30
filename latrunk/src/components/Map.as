package components 
{
	import com.adobe.images.JPGEncoder;
	import com.bit101.components.Label;
	import com.greensock.transform.TransformManager;
	import events.MapObjectEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import model.vo.ObjectInstance;
	
	public class Map extends Sprite
	{
		[Embed(source = '../../lib/paper1.jpg')] public var paperClass:Class;
		
		public var tm:TransformManager;
		public var mapObjects:Vector.<MapObjectInstance> = new Vector.<MapObjectInstance>();
		public var background:Sprite;
		public var grid:Sprite;
		public var mapObjectsHolder:Sprite;
		public var paperTextureHolder:Sprite;
		public var imageRoot:File;
		public var coordinatesLabel:Label;
		
		private var _lastMousePos:Point;
		private var _groupingDirty:Boolean = false;
		private var _paperTexture:BitmapData;
		
		//Blueprint exporting
		private var _exportBitmapDataArray:Array;
		private var _blueprintsName:String;
		
		public function Map() 
		{
			tm = new TransformManager();
			tm.allowMultiSelect = false;
			tm.arrowKeysMove = true;
			tm.hideCenterHandle = true;
			tm.autoDeselect = false;
			tm.forceSelectionToFront = false;
			tm.allowDelete = true;
			
			background = new Sprite();
			addChild(background);
			background.addEventListener(MouseEvent.MOUSE_DOWN, handleBackgroundPress);
			
			//Draws the little ticks on the map that represent (0, 0)
			mapObjectsHolder = new Sprite();
			addChild(mapObjectsHolder);
			mapObjectsHolder.graphics.lineStyle(3, 0xffffff, 0.2);
			mapObjectsHolder.graphics.moveTo(1.5, 0);
			mapObjectsHolder.graphics.lineTo(25, 0);
			mapObjectsHolder.graphics.moveTo(0, 1.5);
			mapObjectsHolder.graphics.lineTo(0, 25);
			
			//draws the paper texture
			var paperTexture:Bitmap = new paperClass();
			_paperTexture = paperTexture.bitmapData;
			paperTextureHolder = new Sprite();
			paperTextureHolder.mouseEnabled = false;
			addChild(paperTextureHolder);
			paperTextureHolder.blendMode = BlendMode.MULTIPLY;
			paperTextureHolder.alpha = 0.5;
			
			grid = new Sprite();
			grid.mouseEnabled = false;
			grid.mouseChildren = false;
			addChild(grid);
			
			coordinatesLabel = new Label(this, 10, 0);
			coordinatesLabel.textField.textColor = 0xffffff;
			addEventListener(MouseEvent.MOUSE_MOVE, updateCoordinatesLabel);
			
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			
			new PhotoshopDrag(mapObjectsHolder, moveMapTo);
		}
		
		private function handleAddedToStage(e:Event):void
		{
			render();
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			stage.addEventListener(Event.RENDER, handleRender);
			stage.addEventListener(Event.RESIZE, handleStageResize);
		}
		
		public function get mapMousePosition():Point
		{
			return new Point(mapObjectsHolder.mouseX, mapObjectsHolder.mouseY);
		}
		
		public function get mapX():Number
		{
			return -mapObjectsHolder.x;
		}
		
		public function set mapX(value:Number):void
		{
			mapObjectsHolder.x = -value;
			grid.x = mapObjectsHolder.x % 25;
			paperTextureHolder.x = mapObjectsHolder.x % 500;
		}
		
		public function get mapY():Number
		{
			return -mapObjectsHolder.y;
		}
		
		public function set mapY(value:Number):void
		{
			mapObjectsHolder.y = -value;
			grid.y = mapObjectsHolder.y % 25;
			paperTextureHolder.y = mapObjectsHolder.y % 500;
		}
		
		public function createMapObject(id:uint):MapObjectInstance
		{
			var overlay:OverlayInstance = new OverlayInstance();
			var transform:TransformInstance = new TransformInstance(id, tm);
			var mapObject:MapObjectInstance = new MapObjectInstance(id, overlay, transform);
			mapObjects.push(mapObject);
			
			mapObject.addEventListener("positionDirty", handleObjectPositionDirty);
			mapObject.addEventListener("scaleDirty", handleObjectScaleDirty);
			mapObject.addEventListener("rotationDirty", handleObjectRotationDirty);
			mapObject.addEventListener("viewDirty", handleObjectViewDirty);
			mapObject.addEventListener("groupDirty", handleObjectGroupDirty);
			
			_groupingDirty = true;
			stage.invalidate()
			
			return mapObject;
		}
		
		public function deleteMapObject(mapObject:MapObjectInstance):void
		{
			mapObjectsHolder.removeChild(mapObject.overlay);
			if (mapObject.transform.parent) //Can be null if object is deleted via transform manager
				mapObjectsHolder.removeChild(mapObject.transform);
			mapObjects.splice(mapObjects.indexOf(mapObject), 1);
			tm.deselectAll();
		}
		
		public function getMapObjectByID(id:uint):MapObjectInstance
		{
			for (var i:int = 0; i < mapObjects.length; i++) 
			{
				var mapObject:MapObjectInstance = mapObjects[i];
				if (mapObject.id == id)
					return mapObject;
			}
			return null;
		}
		
		public function clearAllObjects():void
		{
			mapObjects.length = 0;
			for (var i:int = mapObjectsHolder.numChildren - 1; i >= 0; i--) 
			{
				mapObjectsHolder.removeChild(mapObjectsHolder.getChildAt(i));
			}
		}
		
		public function saveBlueprint(levelName:String, file:File):void
		{
			_blueprintsName = levelName;
			
			var horizontalSections:Number = Math.ceil(mapObjectsHolder.width / 2880);
			var verticalSections:Number = Math.ceil(mapObjectsHolder.height / 2880);
			
			//break up level into 2880x2880 bitmaps
			_exportBitmapDataArray = [];
			for (var i:int=0; i < verticalSections; i++)
			{
				for (var j:int=0; j < horizontalSections; j++)
				{
					var w:Number = 2880;
					var h:Number = 2880;
					
					if (j == horizontalSections - 1)
					{
						w = mapObjectsHolder.width % 2880;
					}
					
					if (i == verticalSections - 1)
					{
						h = mapObjectsHolder.height % 2880;
					}
					
					var bitmapData:BitmapData = new BitmapData(w, h, true, 0);
					var m:Matrix = new Matrix();
					m.translate(j * -2880, i * -2880);
					bitmapData.draw(mapObjectsHolder, m, null, null, null, true);
					_exportBitmapDataArray.push(bitmapData);
				}
			}
			
			file.browseForDirectory("Select a directory to export into...");
			file.addEventListener(Event.SELECT, handleExportDirectorySelected);
		}
		
		public function moveMapTo(x:Number, y:Number):void
		{
			mapX = x;
			mapY = y;
		}
		
		private function handleBackgroundPress(e:MouseEvent):void 
		{
			if (e.target == background)
				tm.deselectAll();
		}
		
		private function moveMap(e:MouseEvent):void
		{
			var currMousePos:Point = new Point(stage.mouseX, stage.mouseY);
			var diffMouse:Point = currMousePos.subtract(_lastMousePos);
			
			moveMapTo( -(mapObjectsHolder.x + diffMouse.x), -(mapObjectsHolder.y + diffMouse.y));
			
			_lastMousePos = currMousePos;
		}
		
		private function sortObjectsByID(a:MapObjectInstance, b:MapObjectInstance):Number 
		{
			if (a.id < b.id) return -1;
			else return 1;
		}
		
		private function sortObjectsByGroup(a:MapObjectInstance, b:MapObjectInstance):Number
		{
			if (a.group < b.group) return -1;
			else if (a.group == b.group) return sortObjectsByID(a, b);
			else return 1;
		}
		
		private function handleRender(e:Event):void 
		{
			var item:MapObjectInstance;
			var i:int;
			
			if (_groupingDirty)
			{
				var n:Number = mapObjects.length - 1;
				for (i = n; i >= 0; i--)
				{
					item = mapObjects[i];
					if (item.transform.parent) //will not have a parent the first time a new object is created.
						mapObjectsHolder.removeChild(item.transform);
					if (item.overlay.parent) //will not have a parent the first time a new object is created.
						mapObjectsHolder.removeChild(item.overlay);
				}
				var groupSortedObjects:Vector.<MapObjectInstance>;
				if (mapObjects.length > 1)
					 groupSortedObjects = mapObjects.sort(sortObjectsByGroup);
				else
					groupSortedObjects = mapObjects;
				for (i = 0; i < groupSortedObjects.length; i++) 
				{
					item = groupSortedObjects[i];
					mapObjectsHolder.addChild(item.transform);
					mapObjectsHolder.addChild(item.overlay);
				}
				_groupingDirty = false;
			}
		}
		
		private function handleObjectPositionDirty(e:Event):void 
		{
			var mapObject:MapObjectInstance = e.target as MapObjectInstance;
			mapObject.overlay.x = mapObject.x;
			mapObject.overlay.y = mapObject.y;
			mapObject.transform.x = mapObject.x;
			mapObject.transform.y = mapObject.y;
			
			if (mapObject.transformItem.selected)
				mapObject.transformItem.update();
		}
		
		private function handleObjectScaleDirty(e:Event):void 
		{
			var mapObject:MapObjectInstance = e.target as MapObjectInstance;
			mapObject.transform.unrotatedWidth = mapObject.width;
			mapObject.transform.unrotatedHeight = mapObject.height;
			
			if (mapObject.transformItem.selected)
				mapObject.transformItem.update();
		}
		
		private function handleObjectRotationDirty(e:Event):void 
		{
			var mapObject:MapObjectInstance = e.target as MapObjectInstance;
			mapObject.transform.rotation = mapObject.rotation;
			mapObject.overlay.rotation = mapObject.rotation;
			
			if (mapObject.transformItem.selected)
				mapObject.transformItem.update();
		}
		
		private function handleObjectViewDirty(e:Event):void 
		{
			var mapObject:MapObjectInstance = e.target as MapObjectInstance;
			if (mapObject.view != "" && mapObject.view != null)
			{
				var extension:String = mapObject.view.substring(mapObject.view.length - 3).toLowerCase();
				if ((extension == "swf" || extension == "jpg" || extension == "png" || extension == "gif") && imageRoot)
				{
					var imageFile:File = imageRoot.resolvePath(mapObject.view);
					if (imageFile.exists)
					{
						mapObject.overlay.graphic.load(new URLRequest(imageFile.url));
						mapObject.overlay.graphic.contentLoaderInfo.addEventListener(Event.COMPLETE, handleObjectGraphicLoaded);
					}
					else
					{
						var popUp:TestPopUp = new TestPopUp("Image Not Found", "The file " + imageFile.nativePath + " doesn't exist.", 400, 150, false);
						stage.addChild(popUp);
						mapObject.overlay.graphic.unloadAndStop();
					}
				}
				else
				{
					mapObject.overlay.graphic.unloadAndStop();
				}
			}
		}
		
		private function handleObjectGraphicLoaded(e:Event):void 
		{
			var mapObject:MapObjectInstance = e.target.loader.parent.mapObject;
			dispatchEvent(new MapObjectEvent(MapObjectEvent.MAP_GRAPHIC_LOADED, mapObject));
		}
		
		private function handleObjectGroupDirty(e:Event):void 
		{
			_groupingDirty = true;
			stage.invalidate()
		}
		
		private function updateCoordinatesLabel(e:MouseEvent):void 
		{
			coordinatesLabel.text = String( -mapObjectsHolder.x + stage.mouseX) + ", " + String( -mapObjectsHolder.y + stage.mouseY);
		}
		
		private function handleStageResize(e:Event):void 
		{
			render();
		}
		
		private function render():void
		{
			background.graphics.clear();
			background.graphics.beginFill(0x6373BA);
			background.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			background.graphics.endFill();
			
			paperTextureHolder.graphics.clear();
			paperTextureHolder.graphics.beginBitmapFill(_paperTexture);
			paperTextureHolder.graphics.drawRect( -500, -500, stage.stageWidth + 1000, stage.stageHeight + 1000);
			paperTextureHolder.graphics.endFill();
			
			grid.graphics.clear();
			grid.graphics.lineStyle(1, 0xffffff, .1);
			for (var i:int = -25; i < stage.stageWidth + 25; i += 25) 
			{
				grid.graphics.moveTo(i, -25);
				grid.graphics.lineTo(i, stage.stageHeight + 25);
			}
			for (i = -25; i < stage.stageHeight + 25; i += 25)
			{
				grid.graphics.moveTo(-25, i);
				grid.graphics.lineTo(stage.stageWidth + 25, i);
			}
			
			coordinatesLabel.y = stage.stageHeight - 25;
		}
		
		private function handleExportDirectorySelected(e:Event):void 
		{
			Main.showLoadingOverlay("Exporting Blueprints...", false);
			var directory:File = e.target as File;
			setTimeout(exportBlueprintsToDirectory, 10, directory);
		}
		
		private function exportBlueprintsToDirectory(directory:File):void
		{
			var bitmapData:BitmapData;
			var jpegEncoder:JPGEncoder;
			var byteArray:ByteArray;
			var imageFile:File;
			var stream:FileStream = new FileStream();
			
			//write all the bitmaps as jpegs to the desktop
			for (var i:int = 0; i < _exportBitmapDataArray.length; i++)
			{
				bitmapData = _exportBitmapDataArray[i] as BitmapData;
				
				jpegEncoder = new JPGEncoder(60);
				byteArray = jpegEncoder.encode(bitmapData);
				
				imageFile = directory.clone();
				imageFile.nativePath = imageFile.nativePath + File.separator + _blueprintsName + " " + i + ".jpg";
				stream.open(imageFile, FileMode.WRITE);
				stream.writeBytes(byteArray, 0, byteArray.length);
				stream.close();
			}
			
			Main.hideLoadingOverlay();
		}
		
	}

}