package commands 
{
	import model.vo.GameState;
	import mx.managers.HistoryManager;
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.undoablecommand.CommandHistory;
	
	public class CreateNewLevelCommand extends Command
	{
		[Inject]
		public var gameState:GameState;
		
		[Inject]
		public var history:CommandHistory;
		
		override public function execute():void
		{
			gameState.createGameState("Untitled Level");
		}
	}

}