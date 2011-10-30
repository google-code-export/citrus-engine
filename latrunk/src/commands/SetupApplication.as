package commands 
{
	import flash.desktop.NativeApplication;
	import mediators.LAMediator;
	import model.ApplicationModel;
	import model.ProjectModel;
	import org.robotlegs.mvcs.Command;
	
	public class SetupApplication extends Command 
	{
		[Inject]
		public var appModel:ApplicationModel;
		
		[Inject]
		public var projectModel:ProjectModel;
		
		override public function execute():void
		{
			appModel.openApplicationFile();
			
			if (appModel.lastOpenProjectFile && appModel.lastOpenProjectFile.exists)
			{
				projectModel.openProject(appModel.lastOpenProjectFile);
			}
		}
		
	}

}