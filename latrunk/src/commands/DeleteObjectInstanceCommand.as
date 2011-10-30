package commands 
{
	import events.ObjectInstanceEvent;
	import model.vo.GameState;
	import org.robotlegs.utilities.undoablecommand.UndoableCommand;
	
	public class DeleteObjectInstanceCommand extends UndoableCommand
	{
		[Inject]
		public var event:ObjectInstanceEvent;
		
		[Inject]
		public var gameState:GameState;
		
		override protected function doExecute():void
		{
			super.doExecute();
			
			gameState.deleteObject(event.objectInstance);
		}
		
		override protected function undoExecute():void
		{
			super.undoExecute();
			
			gameState.restoreObject(event.objectInstance);
		}
	}

}