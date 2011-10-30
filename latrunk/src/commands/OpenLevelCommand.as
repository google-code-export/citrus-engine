package commands 
{
	import model.vo.GameState;
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.undoablecommand.CommandHistory;
	
	public class OpenLevelCommand extends Command 
	{
		[Inject]
		public var history:CommandHistory;
		
		[Inject]
		public var gameState:GameState;
		
		override public function execute():void
		{
			gameState.openGameState();
		}
	}

}