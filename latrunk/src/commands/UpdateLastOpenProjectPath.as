package commands 
{
	import events.ProjectEvent;
	import model.ApplicationModel;
	import model.ProjectModel;
	import org.robotlegs.mvcs.Command;
	
	public class UpdateLastOpenProjectPath extends Command 
	{
		[Inject]
		public var projectModel:ProjectModel;
		
		[Inject]
		public var appModel:ApplicationModel;
		
		override public function execute():void
		{
			appModel.setLastOpenProjectPath(projectModel.projectFile);
		}
	}

}