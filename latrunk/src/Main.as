package  
{
	import adobe.utils.CustomActions;
	import components.LoadingOverlay;
	import components.Map;
	import components.Sidebar;
	import components.TestPopUp;
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.text.TextFormat;
	
	//Need to put a cancel button on checking for a new version.
	//---------------------------------------Next release
	//You can't delete an object that you can't physically select.
	//TODO Confirmation pop-up before downloading new files.
	//TODO Autogenerate IDE files for FlashDevelop and Flash Professional
	//--------------------------------------1.0
	public class Main extends Sprite 
	{
		public static var loadingOverlay:LoadingOverlay;
		
		public var context:LAContext;
		
		public var map:Map;
		
		public var openProjectMenuItem:NativeMenuItem;
		public var newProjectMenuItem:NativeMenuItem;
		public var chooseRootMenuItem:NativeMenuItem;
		public var chooseSWFMenuItem:NativeMenuItem;
		public var launchSWFMenuItem:NativeMenuItem;
		public var exportBlueprintsMenuItem:NativeMenuItem;
		public var undoMenuItem:NativeMenuItem;
		public var redoMenuItem:NativeMenuItem;
		public var copyMenuItem:NativeMenuItem;
		public var pasteMenuItem:NativeMenuItem;
		public var duplicateMenuItemRight:NativeMenuItem;
		public var duplicateMenuItemLeft:NativeMenuItem;
		public var duplicateMenuItemUp:NativeMenuItem;
		public var duplicateMenuItemDown:NativeMenuItem;
		public var deselectObjectMenuItem:NativeMenuItem;
		public var newGameStateMenuItem:NativeMenuItem;
		public var openGameStateMenuItem:NativeMenuItem;
		public var saveGameStateMenuItem:NativeMenuItem;
		public var saveGameStateAsMenuItem:NativeMenuItem;
		public var exitMenuItem:NativeMenuItem;
		public var tipsMenuItem:NativeMenuItem;
		public var aboutMenuItem:NativeMenuItem;
		public var manualMenuItem:NativeMenuItem;
		public var reportBugMenuItem:NativeMenuItem;
		public var newVersionMenuItem:NativeMenuItem;
		public var updateCodeMenuItem:NativeMenuItem;
		public var updateProjectFilesMenuItem:NativeMenuItem;
		public var bringForwardMenuItem:NativeMenuItem;
		public var bringBackwardMenuItem:NativeMenuItem;
		public var resizeBoundsToGraphicMenuItem:NativeMenuItem;
		public var objectMenu:NativeMenuItem;
		public var sidebar:Sidebar;
		
		public function Main() 
		{
			super();
			context = new LAContext(this);
		}
		
		public static function showLoadingOverlay(text:String, showCancelButton:Boolean = true, size:Number = 30):void
		{
			loadingOverlay.visible = true;
			loadingOverlay.nameField.setTextFormat(new TextFormat("_sans", size));
			loadingOverlay.nameField.text = text;
			loadingOverlay.cancelButton.visible = showCancelButton; //also disables cancelling via keyboard
		}
		
		public static function hideLoadingOverlay():void
		{
			loadingOverlay.visible = false;
		}
		
		public function createChildren():void
		{
			stage.nativeWindow.width = 800;
			stage.nativeWindow.height = 600;
			
			stage.scaleMode = "noScale";
			stage.align = "topLeft";
			stage.stageFocusRect = false;
			
			map = new Map();
			addChild(map);
			
			//Create the appropriate menu depending on the OS.
			var nativeMenu:NativeMenu;
			if (NativeApplication.supportsMenu)
			{
				NativeApplication.nativeApplication.menu = new NativeMenu();
				nativeMenu = NativeApplication.nativeApplication.menu;
			}
			else if (NativeWindow.supportsMenu)
			{
				stage.nativeWindow.menu = new NativeMenu();
				nativeMenu = stage.nativeWindow.menu;
			}
			
			var projectMenu:NativeMenuItem = new NativeMenuItem("Project");
			projectMenu.submenu = new NativeMenu();
			nativeMenu.addItem(projectMenu);
			
			var editMenu:NativeMenuItem = new NativeMenuItem("Edit");
			editMenu.submenu = new NativeMenu();
			nativeMenu.addItem(editMenu);
			
			objectMenu = new NativeMenuItem("Object");
			objectMenu.submenu = new NativeMenu();
			nativeMenu.addItem(objectMenu);
			
			var optionsMenu:NativeMenuItem = new NativeMenuItem("Options");
			optionsMenu.submenu = new NativeMenu();
			nativeMenu.addItem(optionsMenu);
			
			var helpMenu:NativeMenuItem = new NativeMenuItem("Help");
			helpMenu.submenu = new NativeMenu();
			nativeMenu.addItem(helpMenu);
			
			launchSWFMenuItem = new NativeMenuItem("Launch SWF");
			launchSWFMenuItem.keyEquivalent = "l";
			projectMenu.submenu.addItem(launchSWFMenuItem);
			
			projectMenu.submenu.addItem(new NativeMenuItem("", true));
			
			newProjectMenuItem = new NativeMenuItem("New Project...");
			newProjectMenuItem.keyEquivalent = "N";
			projectMenu.submenu.addItem(newProjectMenuItem);
			
			openProjectMenuItem = new NativeMenuItem("Open Project...");
			openProjectMenuItem.keyEquivalent = "O";
			projectMenu.submenu.addItem(openProjectMenuItem);
			
			projectMenu.submenu.addItem(new NativeMenuItem("", true));
			
			newGameStateMenuItem = new NativeMenuItem("New Level");
			newGameStateMenuItem.keyEquivalent = "n";
			projectMenu.submenu.addItem(newGameStateMenuItem);
			
			openGameStateMenuItem = new NativeMenuItem("Open Level...");
			openGameStateMenuItem.keyEquivalent = "o";
			projectMenu.submenu.addItem(openGameStateMenuItem);
			
			saveGameStateMenuItem = new NativeMenuItem("Save Level");
			saveGameStateMenuItem.keyEquivalent = "s";
			projectMenu.submenu.addItem(saveGameStateMenuItem);
			
			saveGameStateAsMenuItem = new NativeMenuItem("Save Level As...");
			saveGameStateAsMenuItem.keyEquivalent = "S";
			projectMenu.submenu.addItem(saveGameStateAsMenuItem);
			
			projectMenu.submenu.addItem(new NativeMenuItem("", true));
			
			chooseRootMenuItem = new NativeMenuItem("Choose Root...");
			projectMenu.submenu.addItem(chooseRootMenuItem);
			
			chooseSWFMenuItem = new NativeMenuItem("Choose SWF...");
			projectMenu.submenu.addItem(chooseSWFMenuItem);
			
			exportBlueprintsMenuItem = new NativeMenuItem("Export Level to Image...");
			projectMenu.submenu.addItem(exportBlueprintsMenuItem);
			
			projectMenu.submenu.addItem(new NativeMenuItem("", true));
			
			exitMenuItem = new NativeMenuItem("Quit");
			projectMenu.submenu.addItem(exitMenuItem);
			exitMenuItem.addEventListener(Event.SELECT, handleExitMenuItemPress);
			
			undoMenuItem = new NativeMenuItem("Undo");
			undoMenuItem.keyEquivalent = "z";
			editMenu.submenu.addItem(undoMenuItem);
			
			redoMenuItem = new NativeMenuItem("Redo");
			redoMenuItem.keyEquivalent = "y";
			editMenu.submenu.addItem(redoMenuItem);
			
			editMenu.submenu.addItem(new NativeMenuItem("", true));
			
			copyMenuItem = new NativeMenuItem("Copy Object");
			copyMenuItem.keyEquivalent = "c";
			editMenu.submenu.addItem(copyMenuItem);
			
			pasteMenuItem = new NativeMenuItem("Paste Object");
			pasteMenuItem.keyEquivalent = "v";
			editMenu.submenu.addItem(pasteMenuItem);
			
			editMenu.submenu.addItem(new NativeMenuItem("", true));
			
			duplicateMenuItemRight = new NativeMenuItem("Duplicate Object Right");
			duplicateMenuItemRight.keyEquivalent = "r";
			editMenu.submenu.addItem(duplicateMenuItemRight);
			
			duplicateMenuItemLeft = new NativeMenuItem("Duplicate Object Left");
			duplicateMenuItemLeft.keyEquivalent = "e";
			editMenu.submenu.addItem(duplicateMenuItemLeft);
			
			duplicateMenuItemUp = new NativeMenuItem("Duplicate Object Up");
			duplicateMenuItemUp.keyEquivalent = "u";
			editMenu.submenu.addItem(duplicateMenuItemUp);
			
			duplicateMenuItemDown = new NativeMenuItem("Duplicate Object Down");
			duplicateMenuItemDown.keyEquivalent = "j";
			editMenu.submenu.addItem(duplicateMenuItemDown);
			
			editMenu.submenu.addItem(new NativeMenuItem("", true));
			
			deselectObjectMenuItem = new NativeMenuItem("Deselect Object");
			deselectObjectMenuItem.keyEquivalent = "d";
			editMenu.submenu.addItem(deselectObjectMenuItem);
			
			editMenu.submenu.addItem(new NativeMenuItem("", true));
			
			bringForwardMenuItem = new NativeMenuItem("Bring Object Forward");
			bringForwardMenuItem.keyEquivalent = "]";
			editMenu.submenu.addItem(bringForwardMenuItem);
			
			bringBackwardMenuItem = new NativeMenuItem("Bring Object Backward");
			bringBackwardMenuItem.keyEquivalent = "[";
			editMenu.submenu.addItem(bringBackwardMenuItem);
			
			manualMenuItem = new NativeMenuItem("Level Architect Owner's Manual");
			helpMenu.submenu.addItem(manualMenuItem);
			manualMenuItem.addEventListener(Event.SELECT, handleManualClick);
			
			tipsMenuItem = new NativeMenuItem("Level Architect Tips");
			helpMenu.submenu.addItem(tipsMenuItem);
			tipsMenuItem.addEventListener(Event.SELECT, handleTipsMenuItemClick);
			
			reportBugMenuItem = new NativeMenuItem("Report a Bug");
			helpMenu.submenu.addItem(reportBugMenuItem);
			reportBugMenuItem.addEventListener(Event.SELECT, handleReportBugItemClick);
			
			helpMenu.submenu.addItem(new NativeMenuItem("", true));
			
			aboutMenuItem = new NativeMenuItem("About Level Architect");
			helpMenu.submenu.addItem(aboutMenuItem);
			aboutMenuItem.addEventListener(Event.SELECT, handleAboutItemClick);
			
			newVersionMenuItem = new NativeMenuItem("Check for New Version");
			helpMenu.submenu.addItem(newVersionMenuItem);
			
			updateCodeMenuItem = new NativeMenuItem("Download Citrus Engine Code");
			helpMenu.submenu.addItem(updateCodeMenuItem);
			
			updateProjectFilesMenuItem = new NativeMenuItem("Download New Project Files");
			helpMenu.submenu.addItem(updateProjectFilesMenuItem);
			
			resizeBoundsToGraphicMenuItem = new NativeMenuItem("Resize Bounding Box to Graphic");
			optionsMenu.submenu.addItem(resizeBoundsToGraphicMenuItem);
			
			sidebar = new Sidebar(map);
			addChild(sidebar);
			
			loadingOverlay = new LoadingOverlay();
			stage.addChild(loadingOverlay);
			loadingOverlay.visible = false;
		}
		
		private function handleExitMenuItemPress(e:Event):void 
		{
			NativeApplication.nativeApplication.exit();
		}
		
		private function handleManualClick(e:Event):void 
		{
			navigateToURL(new URLRequest("https://docs.google.com/document/pub?id=1fVTAg6EET9znfCRHzlqF-ByJqFvScacGt0DerIJY4L0"));
		}
		
		private function handleTipsMenuItemClick(e:Event):void 
		{
			navigateToURL(new URLRequest("http://citrusengine.com/forum/viewtopic.php?f=6&t=178"));
		}
		
		private function handleReportBugItemClick(e:Event):void 
		{
			navigateToURL(new URLRequest("http://citrusengine.com/forum/viewforum.php?f=3"));
		}
		
		private function handleAboutItemClick(e:Event):void 
		{
			var message:String = 	"Level Architect version " + getAppVersion() + "\n" +
									"Copyright Blueflame Development LLC\nVisit citrusengine.com for more info about the Citrus Engine and the Level Architect.";
			var popUp:TestPopUp = new TestPopUp("About Citrus Engine", message, 400, 300, false);
			stage.addChild(popUp);
		}
		
		private function getAppVersion():String
		{
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			//return String(appXml.ns::version[0]);
			//NOTE: in Adobe AIR versions 2.5 and up you should comment the above line and uncomment the line below:
			return String(appXml.ns::versionNumber[0]);
		}
	}

}