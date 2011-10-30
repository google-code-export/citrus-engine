package model 
{
	import com.adobe.serialization.json.JSON;
	import events.ProjectEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import model.vo.GameState;
	import org.robotlegs.mvcs.Actor;
	
	public class ProjectModel extends Actor
	{
		//A string pointing to the last saved project file location
		private var _projectFile:File;
		//A string pointing to the project's root, relative to the project file path
		private var _rootPath:String = "..";
		//A string pointing to the swf file, relative to the root path;
		private var _swfPath:String;
		
		public function get projectFilePath():String
		{
			return _projectFile.url;
		}
		
		public function get rootPath():String
		{
			return _rootPath;
		}
		
		public function set rootPath(value:String):void
		{
			_rootPath = value;
			dispatch(new ProjectEvent(ProjectEvent.PROJECT_ROOT_UPDATED));
		}
		
		public function get swfPath():String
		{
			return _swfPath;
		}
		
		public function set swfPath(value:String):void
		{
			if (_swfPath == value)
				return;
				
			_swfPath = value;
			
			//validate this swf exists
			if (_swfPath != null)
			{
				var swfFile:File = getSWFFile();
				if (!swfFile || !swfFile.exists)
				{
					_swfPath = null;
					dispatch(new ProjectEvent(ProjectEvent.SWF_PATH_BROKEN));
				}
			}
			dispatch(new ProjectEvent(ProjectEvent.SWF_PATH_UPDATED));
		}
		
		public function get projectFile():File
		{
			return _projectFile;
		}
		
		public function getProjectRootDirectory():File
		{
			if (_projectFile)
				return _projectFile.resolvePath(_rootPath);
			
			return null;
		}
		
		public function getSWFFile():File
		{
			var rootDirectory:File = getProjectRootDirectory();
			
			if (rootDirectory && _swfPath)
				return rootDirectory.resolvePath(_swfPath);
			
			return null;
		}
		
		public function createNewProject():void
		{
			var file:File = new File();
			file.browseForSave("Choose a location for your new Citrus Engine project");
			file.addEventListener(Event.SELECT, handleSelectNewProjectLocation);
		}
		
		public function openProject(file:File = null):void
		{
			if (file)
			{
				_projectFile = file;
				dispatch(new ProjectEvent(ProjectEvent.PROJECT_OPENED));
				readProjectFile();
			}
			else
			{
				file = new File();
				file.browseForOpen("Open Citrus Engine Project", [new FileFilter("Citrus Engine Project", "*.ce")]);
				file.addEventListener(Event.SELECT, handleFileOpen, false, 0, true);
			}
			
		}
		
		public function saveProject(fallBackToSaveAs:Boolean = true):void
		{
			if (_projectFile)
			{
				var fileStream:FileStream = new FileStream();
				var serializedProjectData:Object = serializeData();
				
				fileStream.open(_projectFile, FileMode.WRITE);
				fileStream.writeUTFBytes(JSON.encode(serializedProjectData));
				fileStream.close();
				
				dispatch(new ProjectEvent(ProjectEvent.PROJECT_SAVED));
			}
			else if (fallBackToSaveAs)
			{
				saveProjectAs();
			}
		}
		
		public function saveProjectAs():void
		{
			var file:File = new File();
			file.browseForSave("Save Project");
			file.addEventListener(Event.SELECT, handleFileSaveAs, false, 0, true);
		}
		
		public function chooseRoot():void
		{
			var file:File = _projectFile.clone();
			file.browseForDirectory("Choose Project Root Folder");
			file.addEventListener(Event.SELECT, handleRootChosen);
		}
		
		public function chooseSWF():void
		{
			var file:File = getProjectRootDirectory();
			file.browseForOpen("Locate your game's SWF");
			file.addEventListener(Event.SELECT, handleSWFChosen);
		}
		
		public function launchSWF():void
		{
			var file:File = getSWFFile();
			file.openWithDefaultApplication();
		}
		
		private function serializeData():Object
		{
			var object:Object = { };
			if (_rootPath)
				object.rootPath = _rootPath;
			if (_swfPath)
				object.swfPath = _swfPath;
			
			return object;
		}
		
		private function deserializeData(fileData:Object):void
		{
			rootPath = fileData.rootPath;
			swfPath = fileData.swfPath;
		}
		
		private function handleFileOpen(e:Event):void
		{
			_projectFile = File(e.target);
			dispatch(new ProjectEvent(ProjectEvent.PROJECT_OPENED));
			readProjectFile();
		}
		
		private function handleFileSaveAs(e:Event):void
		{
			_projectFile = File(e.target);
			
			if (!_projectFile.extension || _projectFile.extension != "ce")
				_projectFile.nativePath += ".ce";
				
			saveProject();
			dispatch(new ProjectEvent(ProjectEvent.PROJECT_ROOT_UPDATED));
		}
		
		private function handleSelectNewProjectLocation(e:Event):void 
		{
			_projectFile = File(e.target);
			dispatch(new ProjectEvent(ProjectEvent.PROJECT_CREATED));
			dispatch(new ProjectEvent(ProjectEvent.PROJECT_OPENED));
			
			if (!_projectFile.extension || _projectFile.extension != "ce")
				_projectFile.nativePath += ".ce";
				
			rootPath = "..";
			swfPath = null;
			
			saveProject();
		}
		
		private function handleRootChosen(e:Event):void
		{
			rootPath = projectFile.getRelativePath(File(e.target), true);
			saveProject(false);
		}
		
		private function handleSWFChosen(e:Event):void 
		{
			swfPath = getProjectRootDirectory().getRelativePath(File(e.target), true);
			saveProject(false);
		}
		
		private function readProjectFile():void
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(_projectFile, FileMode.READ);
			var fileData:Object = JSON.decode(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
			
			deserializeData(fileData);
		}
	}

}