package mediators 
{
	import com.greensock.easing.Back;
	import com.greensock.TweenMax;
	import components.MapObjectInstance;
	import components.TestPopUp;
	import events.CodeDownloadEvent;
	import events.GameStateEvent;
	import events.ObjectInstanceEvent;
	import events.ProjectEvent;
	import events.SoftwareUpdateEvent;
	import events.UpdateObjectPropertyEvent;
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.KeyboardEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import model.ApplicationModel;
	import model.AssetModel;
	import model.ProjectModel;
	import model.vo.GameState;
	import model.vo.ObjectInstance;
	import model.vo.PropertyUpdateVO;
	import org.robotlegs.mvcs.Mediator;
	import org.robotlegs.utilities.undoablecommand.CommandHistory;
	import org.robotlegs.utilities.undoablecommand.HistoryEvent;
	
	public class LAMediator extends Mediator 
	{
		[Inject]
		public var view:Main;
		
		[Inject]
		public var projectModel:ProjectModel;
		
		[Inject]
		public var assetModel:AssetModel;
		
		[Inject]
		public var gameState:GameState;
		
		[Inject]
		public var applicationModel:ApplicationModel;
		
		[Inject]
		public var historyModel:CommandHistory;
		
		public function LAMediator() 
		{
			super();
		}
		
		override public function onRegister():void
		{
			view.createChildren();
			
			view.openProjectMenuItem.addEventListener(Event.SELECT, handleOpenButtonClick);
			view.newProjectMenuItem.addEventListener(Event.SELECT, handleNewProjectButtonClick);
			view.chooseRootMenuItem.addEventListener(Event.SELECT, handleChooseRootButtonClick);
			view.chooseSWFMenuItem.addEventListener(Event.SELECT, handleChooseSWFButtonClick);
			view.launchSWFMenuItem.addEventListener(Event.SELECT, handleLaunchSWFButtonClick);
			view.undoMenuItem.addEventListener(Event.SELECT, handleUndoButtonClick);
			view.redoMenuItem.addEventListener(Event.SELECT, handleRedoButtonClick);
			view.newGameStateMenuItem.addEventListener(Event.SELECT, handleNewGameStatePress);
			view.openGameStateMenuItem.addEventListener(Event.SELECT, handleOpenGameStateButtonClick);
			view.saveGameStateMenuItem.addEventListener(Event.SELECT, handleSaveGameStateButtonClick);
			view.saveGameStateAsMenuItem.addEventListener(Event.SELECT, handleSaveGameStateAsButtonClick);
			view.copyMenuItem.addEventListener(Event.SELECT, handleCopyButtonClick);
			view.pasteMenuItem.addEventListener(Event.SELECT, handlePasteButtonClick);
			view.duplicateMenuItemRight.addEventListener(Event.SELECT, handleDuplicateRightClick);
			view.duplicateMenuItemLeft.addEventListener(Event.SELECT, handleDuplicateLeftClick);
			view.duplicateMenuItemUp.addEventListener(Event.SELECT, handleDuplicateUpClick);
			view.duplicateMenuItemDown.addEventListener(Event.SELECT, handleDuplicateDownClick);
			view.deselectObjectMenuItem.addEventListener(Event.SELECT, handleDeselectObjectClick);
			view.newVersionMenuItem.addEventListener(Event.SELECT, handleNewVersionItemClick);
			view.exportBlueprintsMenuItem.addEventListener(Event.SELECT, handleExportBlueprintsClick);
			view.updateCodeMenuItem.addEventListener(Event.SELECT, handleUpdateCodeClick);
			view.updateProjectFilesMenuItem.addEventListener(Event.SELECT, handleUpdateProjectFilesClick);
			view.bringForwardMenuItem.addEventListener(Event.SELECT, handleBringForwardBackwardClick);
			view.bringBackwardMenuItem.addEventListener(Event.SELECT, handleBringForwardBackwardClick);
			view.resizeBoundsToGraphicMenuItem.addEventListener(Event.SELECT, handleResizeBoundsToGraphicClick);
			
			view.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			view.stage.addEventListener(Event.DEACTIVATE, handleStageDeactivated); //Listen for deactivate before activate in order to keep the activate event from firing upon open.
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, handleApplicationInvoke);
			Main.loadingOverlay.addEventListener(Event.CANCEL, handleCancelZipDownload);
			
			eventMap.mapListener(eventDispatcher, ProjectEvent.PROJECT_CREATED, handleProjectCreated);
			eventMap.mapListener(eventDispatcher, ProjectEvent.PROJECT_SAVED, handleProjectSaved);
			eventMap.mapListener(eventDispatcher, ProjectEvent.PROJECT_ROOT_UPDATED, handleProjectOpened);
			eventMap.mapListener(eventDispatcher, ProjectEvent.SWF_PATH_UPDATED, handleSWFPathUpdated);
			eventMap.mapListener(eventDispatcher, ProjectEvent.SWF_PATH_BROKEN, handleSWFPathBroken);
			eventMap.mapListener(eventDispatcher, ObjectInstanceEvent.OBJECT_CREATED, handleInstanceCreated, ObjectInstanceEvent);
			eventMap.mapListener(eventDispatcher, ObjectInstanceEvent.OBJECT_DELETED, handleObjectDeleted, ObjectInstanceEvent);
			eventMap.mapListener(eventDispatcher, ObjectInstanceEvent.OBJECT_RENAMED, handleObjectRenamed, ObjectInstanceEvent);
			eventMap.mapListener(eventDispatcher, ObjectInstanceEvent.OBJECT_SELECTED, handleObjectSelected, ObjectInstanceEvent);
			eventMap.mapListener(eventDispatcher, ObjectInstanceEvent.ADDED_TO_CLIPBOARD, handleObjectAddedToClipboard, ObjectInstanceEvent);
			eventMap.mapListener(eventDispatcher, UpdateObjectPropertyEvent.OBJECT_PROPERTY_UPDATED, handleObjectPropertyUpdated, UpdateObjectPropertyEvent);
			eventMap.mapListener(eventDispatcher, ObjectInstanceEvent.OBJECT_DELETED, handleObjectInstanceDeleted, ObjectInstanceEvent);
			eventMap.mapListener(eventDispatcher, HistoryEvent.STEP_FORWARD_COMPLETE, handleHistoryEvent, HistoryEvent);
			eventMap.mapListener(eventDispatcher, HistoryEvent.STEP_BACKWARD_COMPLETE, handleHistoryEvent, HistoryEvent);
			eventMap.mapListener(eventDispatcher, HistoryEvent.CLEAR_HISTORY, handleHistoryEvent, HistoryEvent);
			eventMap.mapListener(eventDispatcher, GameStateEvent.GAME_STATE_OPENED, handleGameStateOpened);
			eventMap.mapListener(eventDispatcher, GameStateEvent.GAME_STATE_SAVED, handleGameStateSaved);
			eventMap.mapListener(eventDispatcher, SoftwareUpdateEvent.NEW_VERSION_RESULT, handleNewSoftwareVersionResult);
			eventMap.mapListener(eventDispatcher, SoftwareUpdateEvent.CHECK_VERSION_ERROR, handleCheckNewVersionError);
			eventMap.mapListener(eventDispatcher, SoftwareUpdateEvent.NEW_VERSION_DOWNLOADED, handleNewVersionDownloaded);
			
			updateChooseSWFEnabled();
			updateChooseRootEnabled();
			updateLaunchSWFButtonEnabled();
			updateStepButtonsEnabled();
			updateOpenSaveLevelButtonsEnabled();
			updateInstanceList();
			updateWindowTitle();
			updateCopyButtonEnabled();
			updatePasteButtonEnabled();
			updateDuplicateButtonsEnabled();
			updateDeselectObjectButtonEnabled();
			updateExportBlueprintButtonEnabled();
			updateUpdateCodeButtonEnabled();
			updateBringForwardBackwardButtonsEnabled();
			
			setTimeout(checkForFirstRun, 1);
		}
		
		private function updateResizeBoundsToGraphicButtonEnabled():void 
		{
			view.resizeBoundsToGraphicMenuItem.checked = applicationModel.resizeBoundsToGraphic;
		}
		
		private function checkForFirstRun():void
		{
			if (applicationModel.checkForFirstRun())
			{
				var popUp:TestPopUp = new TestPopUp("Welcome!", "Since this is your first time, we're going to ask you to make a new project right away.\n\nBefore getting started, be sure to read through how to use the Level Architect and the Citrus Engine. You can get tutorials and help by visiting the 'Help' menu above.", 500, 400, false);
				view.stage.addChild(popUp);
				popUp.addEventListener("responseCancel", handleFirstRunPopUpClose);
			}
			updateResizeBoundsToGraphicButtonEnabled(); //check this here, because then we know the application file is opened or written
		}
		
		private function handleFirstRunPopUpClose(e:Event):void 
		{
			TestPopUp(e.target).removeEventListener("responseCancel", handleFirstRunPopUpClose);
			projectModel.createNewProject();
		}
		
		private function handleOpenButtonClick(e:Event):void 
		{
			projectModel.openProject();
		}
		
		private function handleNewProjectButtonClick(e:Event):void
		{
			projectModel.createNewProject();
		}
		
		private function handleChooseRootButtonClick(e:Event):void 
		{
			projectModel.chooseRoot();
		}
		
		private function handleChooseSWFButtonClick(e:Event):void 
		{
			projectModel.chooseSWF();
		}
		
		private function handleLaunchSWFButtonClick(e:Event):void 
		{
			projectModel.launchSWF();
		}
		
		private function handleUndoButtonClick(e:Event):void 
		{
			dispatch(new HistoryEvent(HistoryEvent.STEP_BACKWARD));
			updateStepButtonsEnabled();
		}
		
		private function handleRedoButtonClick(e:Event):void 
		{
			dispatch(new HistoryEvent(HistoryEvent.STEP_FORWARD));
			updateStepButtonsEnabled();
		}
		
		private function handleSWFPathUpdated(e:Event):void 
		{
			updateLaunchSWFButtonEnabled();
		}
		
		private function handleSWFPathBroken(e:ProjectEvent):void 
		{
			var popUp:TestPopUp = new TestPopUp("SWF Not Found", "Your game SWF file may have been moved, renamed, or deleted. Please relink the project to your SWF file using File > Choose SWF...", 400, 300, false);
			view.stage.addChild(popUp);
		}
		
		private function handleInstanceCreated(e:ObjectInstanceEvent):void 
		{
			updateWindowTitle();
			updateInstanceList();
			updateExportBlueprintButtonEnabled();
		}
		
		private function handleObjectRenamed(e:ObjectInstanceEvent):void 
		{
			updateInstanceList();
		}
		
		private function handleObjectSelected(e:ObjectInstanceEvent):void 
		{
			updateCopyButtonEnabled();
			updateDuplicateButtonsEnabled();
			updateDeselectObjectButtonEnabled();
			updateBringForwardBackwardButtonsEnabled();
		}
		
		private function handleObjectAddedToClipboard(e:ObjectInstanceEvent):void 
		{
			updatePasteButtonEnabled();
		}
		
		private function handleObjectDeleted(e:ObjectInstanceEvent):void 
		{
			updateInstanceList();
			updateExportBlueprintButtonEnabled();
		}
		
		private function handleObjectPropertyUpdated(e:UpdateObjectPropertyEvent):void 
		{
			updateWindowTitle();
		}
		
		private function handleObjectInstanceDeleted(e:ObjectInstanceEvent):void 
		{
			updateWindowTitle();
		}
		
		private function handleHistoryEvent(e:HistoryEvent):void 
		{
			updateStepButtonsEnabled();
		}
		
		private function handleGameStateOpened(e:Event):void
		{
			updateLaunchSWFButtonEnabled();
			updateOpenSaveLevelButtonsEnabled()
			updateWindowTitle();
			updateExportBlueprintButtonEnabled();
		}
		
		private function handleGameStateSaved(e:Event):void
		{
			updateWindowTitle();
			updateExportBlueprintButtonEnabled();
		}
		
		private function handleNewGameStatePress(e:Event):void 
		{
			gameState.createGameState("Untitled Level");
		}
		
		private function handleOpenGameStateButtonClick(e:Event):void
		{
			dispatch(new GameStateEvent(GameStateEvent.OPEN_GAME_STATE));
		}
		
		private function handleSaveGameStateButtonClick(e:Event):void 
		{
			gameState.saveGameState();
		}
		
		private function handleSaveGameStateAsButtonClick(e:Event):void 
		{
			gameState.saveGameStateAs();
		}
		
		private function handleCopyButtonClick(e:Event):void 
		{
			gameState.copyToClipboard(gameState.selectedObject);
		}
		
		private function handlePasteButtonClick(e:Event):void 
		{
			gameState.pasteFromClipboard();
		}
		
		private function handleDuplicateRightClick(e:Event):void 
		{
			gameState.copyToClipboard(gameState.selectedObject);
			var newX:Number = Number(gameState.clipboard.getParamByName("x").value) + Number(gameState.clipboard.getParamByName("width").value);
			var newY:Number = Number(gameState.clipboard.getParamByName("y").value);
			gameState.pasteFromClipboard(new Point(newX, newY));
		}
		
		private function handleDuplicateLeftClick(e:Event):void 
		{
			gameState.copyToClipboard(gameState.selectedObject);
			var newX:Number = Number(gameState.clipboard.getParamByName("x").value) - Number(gameState.clipboard.getParamByName("width").value);
			var newY:Number = Number(gameState.clipboard.getParamByName("y").value);
			gameState.pasteFromClipboard(new Point(newX, newY));
		}
		
		private function handleDuplicateUpClick(e:Event):void 
		{
			gameState.copyToClipboard(gameState.selectedObject);
			var newX:Number = Number(gameState.clipboard.getParamByName("x").value);
			var newY:Number = Number(gameState.clipboard.getParamByName("y").value) - Number(gameState.clipboard.getParamByName("height").value);
			gameState.pasteFromClipboard(new Point(newX, newY));
		}
		
		private function handleDuplicateDownClick(e:Event):void 
		{
			gameState.copyToClipboard(gameState.selectedObject);
			var newX:Number = Number(gameState.clipboard.getParamByName("x").value);
			var newY:Number = Number(gameState.clipboard.getParamByName("y").value) + Number(gameState.clipboard.getParamByName("height").value);
			gameState.pasteFromClipboard(new Point(newX, newY));
		}
		
		private function handleDeselectObjectClick(e:Event):void 
		{
			gameState.selectedObject = null;
		}
		
		private function handleProjectCreated(e:ProjectEvent):void 
		{
			var popUp:TestPopUp = new TestPopUp("Download Project Files?", "Would you like to automatically download and install all the Citrus Engine code?\n\nOnly choose 'No' if you are going to set up your project manually.", 400, 300, true);
			view.stage.addChild(popUp);
			popUp.addEventListener("responseYes", acceptDownloadNewProjectFiles, false, 0, true);
		}
		
		private function acceptDownloadNewProjectFiles(e:Event):void 
		{
			Main.showLoadingOverlay("Downloading Project Files...");
			applicationModel.updateCECode("http://citrusengine.com/cecode.zip", projectModel.getProjectRootDirectory().resolvePath("engine"), true);
			eventMap.mapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_PROGRESS, handleFileDownloadProgress);
			eventMap.mapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_COMPLETE, handleNewCodeDownloadComplete);
			eventMap.mapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_ERROR, handleNewCodeDownloadError);
		}
		
		private function handleProjectSaved(e:Event):void 
		{
			updateChooseRootEnabled();
			updateChooseSWFEnabled();
			updateWindowTitle();
			updateExportBlueprintButtonEnabled();
			updateUpdateCodeButtonEnabled();
		}
		
		private function handleProjectOpened(e:Event):void 
		{
			updateChooseRootEnabled();
			updateChooseSWFEnabled();
			updateWindowTitle();
			updateExportBlueprintButtonEnabled();
			updateOpenSaveLevelButtonsEnabled();
			updateUpdateCodeButtonEnabled();
		}
		
		private function updateLaunchSWFButtonEnabled():void
		{
			var swfFile:File = projectModel.getSWFFile();
			view.launchSWFMenuItem.enabled = Boolean(swfFile && swfFile.exists);
		}
		
		private function updateStepButtonsEnabled():void
		{
			view.undoMenuItem.enabled = historyModel.canStepBackward;
			view.redoMenuItem.enabled = historyModel.canStepForward;
		}
		
		private function updateOpenSaveLevelButtonsEnabled():void
		{
			view.openGameStateMenuItem.enabled = Boolean(projectModel.projectFile);
			view.saveGameStateMenuItem.enabled = Boolean(projectModel.projectFile);
			view.saveGameStateAsMenuItem.enabled = Boolean(projectModel.projectFile);
		}
		
		private function updateWindowTitle():void
		{
			var projectTitle:String = projectModel.projectFile ? projectModel.projectFile.name : "Untitled Project";
			var levelTitle:String = gameState.gameStateFile ? gameState.gameStateFile.name : "Untitled Level";
			var saved:String = gameState.isFileOutOfDate ? " * " : "";
			view.stage.nativeWindow.title = projectTitle + " : " + levelTitle + saved + " : " + "Level Architect";
		}
		
		private function updateCopyButtonEnabled():void 
		{
			view.copyMenuItem.enabled = Boolean(gameState.selectedObject);
		}
		
		private function updatePasteButtonEnabled():void 
		{
			view.pasteMenuItem.enabled = Boolean(gameState.clipboard);
		}
		
		private function updateDuplicateButtonsEnabled():void 
		{
			view.duplicateMenuItemRight.enabled = Boolean(gameState.selectedObject);
			view.duplicateMenuItemLeft.enabled = Boolean(gameState.selectedObject);
			view.duplicateMenuItemUp.enabled = Boolean(gameState.selectedObject);
			view.duplicateMenuItemDown.enabled = Boolean(gameState.selectedObject);
		}
		
		private function updateDeselectObjectButtonEnabled():void
		{
			view.deselectObjectMenuItem.enabled = Boolean(gameState.selectedObject);
		}
		
		private function updateExportBlueprintButtonEnabled():void
		{
			view.exportBlueprintsMenuItem.enabled = Boolean(projectModel.projectFile && gameState.gameStateFile && gameState.objects.length > 0);
		}
		
		private function updateUpdateCodeButtonEnabled():void 
		{
			view.updateCodeMenuItem.enabled = Boolean(projectModel.projectFile);
			view.updateProjectFilesMenuItem.enabled = Boolean(projectModel.projectFile);
		}
		
		private function updateBringForwardBackwardButtonsEnabled():void 
		{
			view.bringForwardMenuItem.enabled = Boolean(gameState.selectedObject);
			view.bringBackwardMenuItem.enabled = Boolean(gameState.selectedObject);
		}
		
		private function updateInstanceList():void 
		{
			view.objectMenu.submenu.removeAllItems();
			
			var n:Number = gameState.objects.length;
			if (n > 0)
			{
				//Loop through each instance and create a menu item.
				for (var i:int = 0; i < n; i++)
				{
					var object:ObjectInstance = gameState.objects[i];
					
					
					var classMenu:NativeMenuItem = view.objectMenu.submenu.getItemByName(object.getUnqualifiedClassName());
					if (!classMenu)
					{
						classMenu = new NativeMenuItem(object.getUnqualifiedClassName());
						classMenu.name = object.getUnqualifiedClassName();
						classMenu.submenu = new NativeMenu();
						view.objectMenu.submenu.addItem(classMenu);
					}
					
					var instanceMenuItem:NativeMenuItem = new NativeMenuItem(object.name);
					instanceMenuItem.addEventListener(Event.SELECT, handleInstanceItemSelect);
					instanceMenuItem.data = object.id;
					classMenu.submenu.addItem(instanceMenuItem);
				}
			}
			else
			{
				var noItemsItem:NativeMenuItem = new NativeMenuItem("Go create an object!");
				noItemsItem.enabled = false;
				view.objectMenu.submenu.addItem(noItemsItem);
			}
		}
		
		private function updateChooseRootEnabled():void
		{
			view.chooseRootMenuItem.enabled = Boolean(projectModel.projectFile);
		}
		
		private function updateChooseSWFEnabled():void
		{
			view.chooseSWFMenuItem.enabled = Boolean(projectModel.projectFile);
		}
		
		private function handleKeyDown(e:KeyboardEvent):void 
		{
			
		}
		
		private function handleInstanceItemSelect(e:Event):void
		{
			//get the object that was selected
			var clickedObject:ObjectInstance = gameState.getObjectByID(e.target.data);
			
			//Tween to it's x/y
			var x:Number = Number(clickedObject.getParamByName("x").value) - view.stage.stageWidth / 2;
			var y:Number = Number(clickedObject.getParamByName("y").value) - view.stage.stageHeight / 2;
			TweenMax.to(view.map, 0.6 , { mapX: x, mapY: y, ease: Back.easeOut } );
			
			//Select the map object
			var mapObject:MapObjectInstance = view.map.getMapObjectByID(e.target.data);
			mapObject.transformItem.selected = true;
		}
		
		private function handleStageDeactivated(e:Event):void 
		{
			view.stage.removeEventListener(Event.DEACTIVATE, handleStageDeactivated);
			view.stage.addEventListener(Event.ACTIVATE, handleStageActivated);
		}
		
		private function handleStageActivated(e:Event):void 
		{
			assetModel.updateAssets();
		}
		
		private function handleApplicationInvoke(e:InvokeEvent):void 
		{
			if (e.arguments[0] == undefined)
				return;
				
			var file:File = new File(e.arguments[0]);
			if (file && file.exists)
				projectModel.openProject(file);
		}
		
		private function handleNewVersionItemClick(e:Event):void 
		{
			Main.showLoadingOverlay("Checking for new version...", false);
			applicationModel.checkForNewSoftwareVersion();
		}
		
		private function handleNewSoftwareVersionResult(e:SoftwareUpdateEvent):void 
		{
			Main.hideLoadingOverlay();
			var popUp:TestPopUp;
			if (e.newVersion)
			{
				popUp = new TestPopUp("New Version Found", "A new version of the Level Architect was found (" + e.version + "). Would you like to download it now?", 400, 300, true);
				popUp.addEventListener("responseYes", handleConfirmUpdateVersion, false, 0, true);
			}
			else
			{
				popUp = new TestPopUp("Up To Date", "You already have the latest version.", 400, 300, false);
			}
			view.stage.addChild(popUp);
		}
		
		private function handleCheckNewVersionError(e:SoftwareUpdateEvent):void 
		{
			Main.hideLoadingOverlay();
			var popUp:TestPopUp = new TestPopUp("Could Not Check", "There was a problem checking for a new version. Please visit citrusengine.com to check the latest version.", 400, 300, false);
			view.stage.addChild(popUp);
		}
		
		private function handleConfirmUpdateVersion(e:Event):void 
		{
			Main.showLoadingOverlay("Downloading new version...", false);
			applicationModel.downloadLatestSoftware();
		}
		
		private function handleNewVersionDownloaded(e:SoftwareUpdateEvent):void 
		{
			Main.hideLoadingOverlay();
			var file:File = new File(e.downloadPath);
			file.openWithDefaultApplication();
		}
		
		private function handleExportBlueprintsClick(e:Event):void 
		{
			setTimeout(saveBlueprint, 10);
		}
		
		private function saveBlueprint():void
		{
			var levelName:String = gameState.gameStateFile.name.substring(0, gameState.gameStateFile.name.length - 4);
			view.map.saveBlueprint(levelName, projectModel.getProjectRootDirectory());
		}
		
		private function handleUpdateCodeClick(e:Event):void 
		{
			Main.showLoadingOverlay("Downloading Citrus Engine Code...");
			var directory:File = projectModel.getProjectRootDirectory().resolvePath("engine");
			applicationModel.updateCECode("http://citrusengine.com/cecode.zip", directory, true);
			eventMap.mapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_COMPLETE, handleUpdateFilesDownloadComplete);
			eventMap.mapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_ERROR, handleUpdateFilesDownloadComplete);
		}
		
		private function handleUpdateProjectFilesClick(e:Event):void 
		{
			Main.showLoadingOverlay("Downloading Project Files...");
			var directory:File = projectModel.getProjectRootDirectory();
			applicationModel.updateCECode("http://citrusengine.com/ceprojectfiles.zip", directory, false);
			eventMap.mapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_COMPLETE, handleUpdateFilesDownloadComplete);
			eventMap.mapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_ERROR, handleUpdateFilesDownloadComplete);
		}
		
		private function handleUpdateFilesDownloadComplete(e:CodeDownloadEvent):void 
		{
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_PROGRESS, handleFileDownloadProgress);
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_COMPLETE, handleUpdateFilesDownloadComplete);
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_ERROR, handleUpdateFilesDownloadComplete);
			Main.hideLoadingOverlay();
		}
		
		private function handleNewCodeDownloadComplete(e:CodeDownloadEvent):void 
		{
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_PROGRESS, handleFileDownloadProgress);
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_COMPLETE, handleNewCodeDownloadComplete);
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_ERROR, handleNewCodeDownloadError);
			
			applicationModel.updateCECode("http://citrusengine.com/ceprojectfiles.zip", projectModel.getProjectRootDirectory(), false);
			eventMap.mapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_PROGRESS, handleFileDownloadProgress);
			eventMap.mapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_COMPLETE, handleNewProjectFilesDownloadComplete);
			eventMap.mapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_ERROR, handleNewProjectFilesDownloadError);
		}
		
		private function handleNewCodeDownloadError(e:CodeDownloadEvent):void 
		{
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_PROGRESS, handleFileDownloadProgress);
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_COMPLETE, handleNewCodeDownloadComplete);
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_ERROR, handleNewCodeDownloadError);
			
			var popUp:TestPopUp = new TestPopUp("Code Download Error", "There was a problem downloading the Citrus Engine code files. Please try again later from the \"Help\" menu.", 400, 300, false);
			view.stage.addChild(popUp);
		}
		
		private function handleFileDownloadProgress(e:CodeDownloadEvent):void
		{
			var progressString:String;
			if (e.data is ProgressEvent)
			{
				var percent:Number = Math.round((e.data.bytesLoaded / e.data.bytesTotal) * 100);
				progressString = percent + "%";
			}
			else
			{
				var name:String = e.data.file.filename;
				progressString = name;
			}
			
			Main.loadingOverlay.nameField.text = progressString;
		}
		
		private function handleNewProjectFilesDownloadComplete(e:CodeDownloadEvent):void 
		{
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_PROGRESS, handleFileDownloadProgress);
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_COMPLETE, handleNewProjectFilesDownloadComplete);
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_ERROR, handleNewProjectFilesDownloadError);
			
			Main.hideLoadingOverlay();
			
			assetModel.updateAssets();
			
			//assume the name of the new swf and set it to be the swfPath
			var projectFileName:String = projectModel.projectFile.name;
			var projectName:String = projectFileName.substring(0, projectFileName.length - 3);
			var newSWFName:String = projectName + ".swf";
			projectModel.swfPath = "bin" + File.separator + newSWFName;
			projectModel.saveProject();
			
			//assume there is a level file named "example" and open it.
			gameState.openGameState(projectModel.getProjectRootDirectory().resolvePath("bin/example.lev"));
			
			var popUp:TestPopUp = new TestPopUp("Project Download Complete", "Project files have been downloaded successfully! We automatically opened an example level called 'example'.\n\nYou can update the Citrus Engine code to the latest version at any time from the \"Help\" menu.", 400, 300, false);
			view.stage.addChild(popUp);
		}
		
		private function handleNewProjectFilesDownloadError(e:CodeDownloadEvent):void 
		{
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_PROGRESS, handleFileDownloadProgress);
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_COMPLETE, handleNewProjectFilesDownloadComplete);
			eventMap.unmapListener(eventDispatcher, CodeDownloadEvent.CODE_DOWNLOAD_ERROR, handleNewProjectFilesDownloadError);
			
			var popUp:TestPopUp = new TestPopUp("Project Download Error", "There was a problem downloading the Citrus Engine project files. Please try again later from the \"Help\" menu.", 400, 300, false);
			view.stage.addChild(popUp);
		}
		
		private function handleCancelZipDownload(e:Event):void 
		{
			applicationModel.cancelCECode();
		}
		
		private function handleBringForwardBackwardClick(e:Event):void 
		{
			var currGroup:int = int(gameState.selectedObject.getParamByName("group").value);
			
			var updates:Array = [];
			if (e.target == view.bringForwardMenuItem)
				updates.push(new PropertyUpdateVO(gameState.selectedObject, "group", currGroup + 1));
			else
				updates.push(new PropertyUpdateVO(gameState.selectedObject, "group", Math.max(0, currGroup - 1)));
			
			dispatch(new UpdateObjectPropertyEvent(UpdateObjectPropertyEvent.UPDATE_OBJECT_PROPERTY, updates));
		}
		
		private function handleResizeBoundsToGraphicClick(e:Event):void 
		{
			applicationModel.resizeBoundsToGraphic = !applicationModel.resizeBoundsToGraphic;
			updateResizeBoundsToGraphicButtonEnabled();
		}
	}

}