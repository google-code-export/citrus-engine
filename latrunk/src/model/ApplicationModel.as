package model 
{
	import com.codeazur.fzip.FZip;
	import com.codeazur.fzip.FZipErrorEvent;
	import com.codeazur.fzip.FZipEvent;
	import com.codeazur.fzip.FZipFile;
	import com.codeazur.utils.AIRRemoteUpdater;
	import com.codeazur.utils.AIRRemoteUpdaterEvent;
	import events.CodeDownloadEvent;
	import events.SoftwareUpdateEvent;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import org.robotlegs.mvcs.Actor;
	
	public class ApplicationModel extends Actor 
	{
		[Inject]
		public var projectModel:ProjectModel;
		
		public static const AIR_REMOTE_LOC:String = "http://citrusengine.com/LevelArchitect.air";
		
		private var _lastOpenProjectFile:File;
		private var _updater:AIRRemoteUpdater;
		private var _firstRun:Boolean = false;
		private var _codeZip:FZip;
		private var currCodeFileIndex:uint = 0;
		private var _zipCodeProcessing:Boolean = false;
		private var _zipCodeWriteInterval:uint;
		private var _codeDirectory:File;
		private var _resizeBoundsToGraphic:Boolean = true;
		
		public function get lastOpenProjectFile():File 
		{
			return _lastOpenProjectFile;
		}
		
		public function get zipCodeProcessing():Boolean 
		{
			return _zipCodeProcessing;
		}
		
		public function get resizeBoundsToGraphic():Boolean
		{
			return _resizeBoundsToGraphic;
		}
		
		public function set resizeBoundsToGraphic(value:Boolean):void
		{
			_resizeBoundsToGraphic = value;
			
			writeToAppFile();
		}
		
		public function openApplicationFile():void
		{
			var file:File = File.applicationStorageDirectory.resolvePath("AppData.fuck");
			if (file.exists)
			{
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				try
				{
					var data:Object = stream.readObject();
					stream.close();
					
					if (!deserialize(data))
						file.deleteFile();
					
				}
				catch (e:Error)
				{
					trace("Error: " + e.message);
					stream.close();
					file.deleteFile();
				}
			}
			else
			{
				_firstRun = true;
			}
		}
		
		public function setLastOpenProjectPath(file:File):void
		{
			_lastOpenProjectFile = file;
			writeToAppFile();
		}
		
		public function checkForNewSoftwareVersion():void
		{
			_updater = new AIRRemoteUpdater();
			_updater.addEventListener(AIRRemoteUpdaterEvent.VERSION_CHECK, handleVersionCheck);
			_updater.addEventListener(FZipErrorEvent.PARSE_ERROR, handleVersionCheckError);
			_updater.addEventListener(IOErrorEvent.IO_ERROR, handleVersionCheckError);
			_updater.update(new URLRequest(AIR_REMOTE_LOC));
		}
		
		public function downloadLatestSoftware():void
		{
			_updater = new AIRRemoteUpdater();
			_updater.addEventListener(AIRRemoteUpdaterEvent.UPDATE, handleNewVersionDownloadComplete);
			_updater.addEventListener(FZipErrorEvent.PARSE_ERROR, handleVersionCheckError);
			_updater.addEventListener(IOErrorEvent.IO_ERROR, handleVersionCheckError);
			_updater.update(new URLRequest(AIR_REMOTE_LOC));
		}
		
		public function checkForFirstRun():Boolean
		{
			return _firstRun;
		}
		
		public function updateCECode(zipURL:String, directory:File, deleteDirectoryFirst:Boolean):void
		{
			if (_zipCodeProcessing)
				return;
				
			_zipCodeProcessing = true;
			_codeDirectory = directory;
			
			if (_codeDirectory.exists && deleteDirectoryFirst)
				_codeDirectory.deleteDirectory(true);
				
			_codeZip = new FZip();
			_codeZip.addEventListener(Event.OPEN, onZipOpen);
			_codeZip.addEventListener(Event.COMPLETE, onZipDownloadComplete);
			_codeZip.addEventListener(IOErrorEvent.IO_ERROR, onZipDownloadError);
			_codeZip.addEventListener(FZipErrorEvent.PARSE_ERROR, onZipParseError);
			_codeZip.addEventListener(ProgressEvent.PROGRESS, handleZipDownloadProgress);
			_codeZip.addEventListener(FZipEvent.FILE_LOADED, handleZipWriteProgress);
			_codeZip.load(new URLRequest(zipURL));
		}
		
		public function cancelCECode():void
		{
			if (!_zipCodeProcessing)
				return;
			
			closeZipDownoad();
		}
		
		private function getAppVersion():String
		{
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			return String(appXml.ns::version[0]);
			//NOTE: in Adobe AIR versions 2.5 and up you should comment the above line and uncomment the line below:
			//return String(appXml.ns::versionNumber[0]);
		}
		
		private function deserialize(data:Object):Boolean
		{
			try
			{
				_lastOpenProjectFile = new File(data.lastOpenProjectPath);
			}
			catch (e:Error)
			{
				trace("Error: " + e.message);
				return false;
			}
			
			_resizeBoundsToGraphic = data.resizeBoundsToGraphic;
			
			return true;
		}
		
		private function serialize():Object
		{
			var data:Object = { };
			data.lastOpenProjectPath = _lastOpenProjectFile.nativePath;
			data.resizeBoundsToGraphic = _resizeBoundsToGraphic;
			return data;
		}
		
		private function writeToAppFile():void
		{
			var file:File = File.applicationStorageDirectory.resolvePath("AppData.fuck");
			var data:Object = serialize();
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeObject(data);
			stream.close();
		}
		
		private function handleVersionCheck(e:AIRRemoteUpdaterEvent):void 
		{
			_updater.removeEventListener(AIRRemoteUpdaterEvent.VERSION_CHECK, handleVersionCheck);
			_updater.removeEventListener(FZipErrorEvent.PARSE_ERROR, handleVersionCheckError);
			_updater.removeEventListener(IOErrorEvent.IO_ERROR, handleVersionCheckError);
			e.preventDefault();
			
			var localNums:Array = _updater.localVersion.split(".");
			var remoteNums:Array = _updater.remoteVersion.split(".");
			
			var foundNewVersion:Boolean = false;
			for (var i:int = 0; i < 3; i++)
			{
				if (Number(remoteNums[i]) > Number(localNums[i]))
				{
					dispatch(new SoftwareUpdateEvent(SoftwareUpdateEvent.NEW_VERSION_RESULT, true, _updater.remoteVersion, AIR_REMOTE_LOC));
					foundNewVersion = true;
					break;
				}
			}
			
			if (!foundNewVersion)
				dispatch(new SoftwareUpdateEvent(SoftwareUpdateEvent.NEW_VERSION_RESULT, false, _updater.remoteVersion, AIR_REMOTE_LOC));
		}
		
		private function handleVersionCheckError(e:Event):void 
		{
			_updater.removeEventListener(AIRRemoteUpdaterEvent.VERSION_CHECK, handleVersionCheck);
			_updater.removeEventListener(FZipErrorEvent.PARSE_ERROR, handleVersionCheckError);
			_updater.removeEventListener(IOErrorEvent.IO_ERROR, handleVersionCheckError);
			dispatch(new SoftwareUpdateEvent(SoftwareUpdateEvent.CHECK_VERSION_ERROR, false, "", AIR_REMOTE_LOC));
		}
		
		private function handleNewVersionDownloadComplete(e:AIRRemoteUpdaterEvent):void 
		{
			dispatch(new SoftwareUpdateEvent(SoftwareUpdateEvent.NEW_VERSION_DOWNLOADED, true, "", e.file.nativePath));
		}
		
		private function onZipOpen(e:Event):void 
		{
			_zipCodeWriteInterval = setInterval(saveCodeToHD, 33);
		}
		
		private function onZipDownloadComplete(e:Event):void 
		{
			_zipCodeProcessing = false;
		}
		
		private function saveCodeToHD():void 
		{
			var zipFile:FZipFile;
			var file:File;
			var stream:FileStream;
			
			// we only want to write 32 files at once to the HD to save a bit of processor load when zip is cached
			for (var i:uint = 0; i < 32; i++)
			{
				// any new files available?
				if (_codeZip.getFileCount() > currCodeFileIndex)
				{
					// yeah, get it
					zipFile = _codeZip.getFileAt(currCodeFileIndex);
					
					//make it
					file = _codeDirectory.resolvePath(zipFile.filename);
					if (file.name.indexOf(".") != -1)
					{
						stream = new FileStream();
						stream.open(file, FileMode.WRITE);
						stream.writeBytes(zipFile.content);
						stream.close();
						
						//Rename Game.swf to be ProjectName.swf (where ProjectName is the name of the project)
						if (file.name == "Game.swf")
						{
							var projectFileName:String = projectModel.projectFile.name;
							var projectName:String = projectFileName.substring(0, projectFileName.length - 3);
							var newSWFName:String = projectName + ".swf";
							if (newSWFName != "Game.swf")
								file.moveTo(file.parent.resolvePath(newSWFName), true);
						}
					}
					else
					{
						file.createDirectory();
					}
					currCodeFileIndex++;
				}
				else
				{
					// no new files available
					// check if we're done
					if (!_zipCodeProcessing)
					{
						closeZipDownoad();
						dispatch(new CodeDownloadEvent(CodeDownloadEvent.CODE_DOWNLOAD_COMPLETE, _codeZip));
					}
					break;
				}
			}
		}
		
		private function onZipDownloadError(e:IOErrorEvent):void 
		{
			closeZipDownoad();
			dispatch(new CodeDownloadEvent(CodeDownloadEvent.CODE_DOWNLOAD_ERROR, _codeZip));
		}
		
		private function onZipParseError(e:FZipErrorEvent):void
		{
			closeZipDownoad();
			dispatch(new CodeDownloadEvent(CodeDownloadEvent.CODE_PARSE_ERROR, _codeZip));
		}
		
		private function handleZipDownloadProgress(e:ProgressEvent):void
		{
			dispatch(new CodeDownloadEvent(CodeDownloadEvent.CODE_DOWNLOAD_PROGRESS, e));
		}
		
		private function handleZipWriteProgress(e:FZipEvent):void 
		{
			dispatch(new CodeDownloadEvent(CodeDownloadEvent.CODE_DOWNLOAD_PROGRESS, e));
		}
		
		private function removeZipDownloadEvents():void
		{
			_codeZip.removeEventListener(Event.OPEN, onZipOpen);
			_codeZip.removeEventListener(Event.COMPLETE, onZipDownloadComplete);
			_codeZip.removeEventListener(IOErrorEvent.IO_ERROR, onZipDownloadError);
			_codeZip.removeEventListener(FZipErrorEvent.PARSE_ERROR, onZipParseError);
			_codeZip.removeEventListener(ProgressEvent.PROGRESS, handleZipDownloadProgress);
			_codeZip.removeEventListener(FZipEvent.FILE_LOADED, handleZipWriteProgress);
		}
		
		private function closeZipDownoad():void
		{
			removeZipDownloadEvents();
			currCodeFileIndex = 0;
			_zipCodeProcessing = false;
			clearInterval(_zipCodeWriteInterval);
			_codeZip.close();
		}
	}

}