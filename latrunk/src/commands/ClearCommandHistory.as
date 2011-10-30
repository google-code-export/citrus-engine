package commands 
{
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.undoablecommand.CommandHistory;
	
	public class ClearCommandHistory extends Command 
	{
		[Inject]
		public var history:CommandHistory;
		
		override public function execute():void
		{
			history.clearHistory();
		}
		
	}

}