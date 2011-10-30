package model.vo 
{
	import events.GameStateEvent;
	import events.ObjectInstanceEvent;
	import events.UpdateObjectPropertyEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.utils.setTimeout;
	import model.AssetModel;
	import org.robotlegs.mvcs.Actor;
	import adobe.utils.CustomActions;
	
	public class GameState extends Actor
	{
		[Inject]
		public var assetModel:AssetModel;
		
		public var lastGroupUsed:int = 0;
		
		private var _name:String = "Untitled Level";
		private var _objects:Vector.<ObjectInstance> = new Vector.<ObjectInstance>();
		private var _gameStateFile:File;
		private var _isFileOutOfDate:Boolean = false;
		private var _selectedObject:ObjectInstance;
		private var _clipboard:ObjectInstance;
		private var _lastObjectID:int = -1;
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
			dispatch(new GameStateEvent(GameStateEvent.GAME_STATE_RENAMED));
		}
		
		public function get objects():Vector.<ObjectInstance>
		{
			return _objects;
		}
		
		public function get gameStateFile():File
		{
			return _gameStateFile;
		}
		
		public function get isFileOutOfDate():Boolean
		{
			return _isFileOutOfDate;
		}
		
		public function set isFileOutOfDate(value:Boolean):void
		{
			_isFileOutOfDate = value;
		}
		
		public function get selectedObject():ObjectInstance
		{
			return _selectedObject;
		}
		
		public function set selectedObject(value:ObjectInstance):void
		{
			if (_selectedObject == value)
				return;
				
			_selectedObject = value;
			dispatch(new ObjectInstanceEvent(ObjectInstanceEvent.OBJECT_SELECTED, _selectedObject));
		}
		
		public function get clipboard():ObjectInstance 
		{
			return _clipboard;
		}
		
		public function getObjectByID(id:uint):ObjectInstance
		{
			for each (var objectInstance:ObjectInstance in _objects)
			{
				if (objectInstance.id == id)
					return objectInstance;
			}
			return null;
		}
		
		public function createObject(object:ObjectAsset, x:Number, y:Number, group:int, dispatchIt:Boolean = true, customSize:Boolean = false, name:String = null):ObjectInstance
		{
			var newParams:Vector.<ObjectInstanceParam> = new Vector.<ObjectInstanceParam>();
			for (var i:int = 0; i < object.params.length; i++)
			{
				var item:ObjectAssetParam = object.params[i];
				if (item.name == "x")
					item.value = x;
				else if (item.name == "y")
					item.value = y;
				else if (item.name == "group")
					item.value = group.toString();
				
				newParams.push(new ObjectInstanceParam(item.name, item.type, item.inherited, item.options));
			}
			_lastObjectID++;
			var objectInstance:ObjectInstance = new ObjectInstance(_lastObjectID, object.className, object.superClassName, newParams, customSize, name);
			_objects.push(objectInstance);
			
			_isFileOutOfDate = true;
			
			if (dispatchIt)
				dispatch(new ObjectInstanceEvent(ObjectInstanceEvent.OBJECT_CREATED, objectInstance));
			
			return objectInstance;
		}
		
		public function copyToClipboard(objectInstance:ObjectInstance):void
		{
			_clipboard = objectInstance.copy(-1);
			dispatch(new ObjectInstanceEvent(ObjectInstanceEvent.ADDED_TO_CLIPBOARD, _clipboard));
		}
		
		public function pasteFromClipboard(newPosition:Point = null):void
		{
			if (_clipboard)
			{
				dispatch(new ObjectInstanceEvent(ObjectInstanceEvent.COPY_OBJECT, _clipboard));
				if (newPosition)
				{
					var updates:Array = [];
					var newObject:ObjectInstance = _objects[_objects.length - 1];
					updates.push(new PropertyUpdateVO(newObject, "x", newPosition.x));
					updates.push(new PropertyUpdateVO(newObject, "y", newPosition.y));
					dispatch(new UpdateObjectPropertyEvent(UpdateObjectPropertyEvent.UPDATE_OBJECT_PROPERTY, updates));
				}
			}
		}
		
		public function deleteObject(object:ObjectInstance):void
		{
			_objects.splice(_objects.indexOf(object), 1);
			_isFileOutOfDate = true;
			dispatch(new ObjectInstanceEvent(ObjectInstanceEvent.OBJECT_DELETED, object));
		}
		
		/**
		 * Used for restoring a deleted object using the reference to the instance that the UndoablCommand holds onto.
		 */
		public function restoreObject(object:ObjectInstance):void
		{
			_objects.push(object);
			_isFileOutOfDate = true;
			dispatch(new ObjectInstanceEvent(ObjectInstanceEvent.OBJECT_CREATED, object));
		}
		
		public function copyObject(object:ObjectInstance, dispatchIt:Boolean = true):ObjectInstance
		{
			_lastObjectID++;
			var objectInstance:ObjectInstance = object.copy(_lastObjectID);
			_objects.push(objectInstance);
			_isFileOutOfDate = true;
			
			if (dispatchIt)
				dispatch(new ObjectInstanceEvent(ObjectInstanceEvent.OBJECT_CREATED, objectInstance));
			
			selectedObject = null;
			setTimeout(function():void { selectedObject = objectInstance; }, 1); //This is a nasty hack b/c TransformManager has a problem with a creation and immeidate selection.
				
			return objectInstance;
		}
		
		public function renameObject(object:ObjectInstance, name:String):void
		{
			object.name = name;
			dispatch(new ObjectInstanceEvent(ObjectInstanceEvent.OBJECT_RENAMED, object));
		}
		
		public function createGameState(name:String):void
		{
			_name = name;
			lastGroupUsed = 0;
			_lastObjectID = -1;
			_objects.length = 0;
			selectedObject = null; //dispatches OBJECT_SELECTED event;
			dispatch(new GameStateEvent(GameStateEvent.ALL_OBJECTS_CLEARED));
			_isFileOutOfDate = false;
			_gameStateFile = null;
			
		}
		
		public function openGameState(file:File = null):void
		{
			if (!file || !file.exists)
			{
				file = new File();
				file.browseForOpen("Open Level File", [new FileFilter("Citrus Engine Level", "*.lev")]);
				file.addEventListener(Event.SELECT, handleFileOpen, false, 0, true);
			}
			else
			{
				_gameStateFile = file;
				var fileStream:FileStream = new FileStream();
				fileStream.open(_gameStateFile, FileMode.READ);
				deserializeFromXML(XML(fileStream.readUTFBytes(fileStream.bytesAvailable)));
				fileStream.close();
				_isFileOutOfDate = false;
				
				dispatch(new GameStateEvent(GameStateEvent.GAME_STATE_OPENED));
			}
		}
		
		public function saveGameState():void
		{
			if (_gameStateFile)
			{
				var fileStream:FileStream = new FileStream();
				var serializedGameStateData:XML = serializeToXML();
				
				fileStream.open(_gameStateFile, FileMode.WRITE);
				fileStream.writeUTFBytes(serializedGameStateData.toString());
				fileStream.close();
				
				_isFileOutOfDate = false;
				
				dispatch(new GameStateEvent(GameStateEvent.GAME_STATE_SAVED));
			}
			else
			{
				saveGameStateAs();
			}
		}
		
		public function saveGameStateAs():void
		{
			var file:File = new File();
			file.browseForSave("Save Level To...");
			file.addEventListener(Event.SELECT, handleGameStateSaveAs);
		}
		
		public function deleteObjectsOfClass(className:String):void
		{
			for each (var object:ObjectInstance in objects)
			{
				if (object.className == className)
					deleteObject(object);
			}
		}
		
		private function handleGameStateSaveAs(e:Event):void
		{
			_gameStateFile = e.target as File;
			
			if (!_gameStateFile.extension || _gameStateFile.extension != "lev")
				_gameStateFile.nativePath += ".lev";
			
			saveGameState();
		}
		
		private function handleFileOpen(e:Event):void
		{
			openGameState(File(e.target));
		}
		
		private function serializeToXML():XML
		{
			//<?xml version="1.0" encoding="UTF-8"?>
			var xml:XML = new XML(<GameState />);
			xml.@name = name;
			
			//Create XML for each OBJECT
			for (var i:int = 0; i < _objects.length; i++) 
			{
				var item:ObjectInstance = _objects[i];
				var objectXML:XML = new XML(<CitrusObject />);
				objectXML.@name = item.name;
				objectXML.@className = item.className;
				
				//Create XML for each PROPERTY on the object.
				for (var j:int = 0; j < item.params.length; j++) 
				{
					var property:ObjectInstanceParam = item.params[j];
					if (property.value != null)
					{
						var propertyXML:XML = new XML(<Property />);
						propertyXML.@name = property.name;
						propertyXML.appendChild(property.value);
						objectXML.appendChild(propertyXML);
					}
				}
				
				xml.appendChild(objectXML);
			}
			
			return xml;
		}
		
		private function deserializeFromXML(value:XML):void
		{
			_name = value.@name;
			selectedObject = null; //dispatches OBJECT_SELECTED event;
			_objects.length = 0;
			dispatch(new GameStateEvent(GameStateEvent.ALL_OBJECTS_CLEARED));
			
			for (var i:int = 0; i < value.CitrusObject.length(); i++)
			{
				var objectXML:XML = value.CitrusObject[i];
				var objectAsset:ObjectAsset = assetModel.getAssetByName(objectXML.@className.toString());
				var params:Vector.<ObjectInstanceParam> = new Vector.<ObjectInstanceParam>();
				if (!objectAsset)
				{
					//TODO Handle when an asset isn't found for an object.
					trace("Object " + objectXML.@name.toString() + ":" + objectXML.@className.toString() + " not found in asset list.\nThis object will not be saved.");
				}
				else
				{
					var instance:ObjectInstance = createObject(objectAsset, 0, 0, 0, true, true, objectXML.@name);
					var propertyUpdates:Array = new Array();
					for (var j:int = 0; j < objectXML.Property.length(); j++) 
					{
						var paramXML:XML = objectXML.Property[j];
						var param:ObjectInstanceParam = instance.getParamByName(paramXML.@name);
						if (!param)
						{
							//TODO Handle when a param isn't found on an object.
							trace("A property named " + paramXML.@name + " was not found on the class of " + instance.name + ":" + instance.className + " and will not be saved.");
						}
						else
						{
							param.value = paramXML.toString();
							propertyUpdates.push(new PropertyUpdateVO(instance, param.name, param.value));
						}
					}
					
					if (propertyUpdates.length > 0)
						dispatch(new UpdateObjectPropertyEvent(UpdateObjectPropertyEvent.OBJECT_PROPERTY_UPDATED, propertyUpdates));
				}
			}
		}
	}

}