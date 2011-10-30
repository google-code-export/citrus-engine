package commands 
{
	import events.CreateObjectInstanceEvent;
	import events.ObjectInstanceEvent;
	import model.vo.GameState;
	import model.vo.ObjectInstance;
	import org.robotlegs.utilities.undoablecommand.UndoableCommand;
	
	public class CopyObjectInstanceCommand extends UndoableCommand 
	{
		[Inject]
		public var event:ObjectInstanceEvent;
		
		[Inject]
		public var gameState:GameState;
		
		private var _objectInstance:ObjectInstance;
		
		override protected function doExecute():void
		{
			super.doExecute();
			
			//Get the number of objects of the particular type, so we can name it usefully generically.
			var numObjectsOfType:uint = 0;
			for each (var object:ObjectInstance in gameState.objects)
			{
				if (object.className == event.objectInstance.className)
				numObjectsOfType++;
			}
			
			_objectInstance = gameState.copyObject(event.objectInstance, event.objectInstance.getUnqualifiedClassName() + numObjectsOfType);
		}
		
		override protected function undoExecute():void
		{
			super.undoExecute();
			
			gameState.deleteObject(_objectInstance);
		}
	}
}