package commands 
{
	import events.CreateObjectInstanceEvent;
	import model.ApplicationModel;
	import model.vo.GameState;
	import model.vo.ObjectInstance;
	import org.robotlegs.utilities.undoablecommand.UndoableCommand;
	
	public class CreateObjectInstanceCommand extends UndoableCommand 
	{
		[Inject]
		public var event:CreateObjectInstanceEvent;
		
		[Inject]
		public var gameState:GameState;
		
		[Inject]
		public var applicationModel:ApplicationModel;
		
		private var _objectInstance:ObjectInstance;
		
		override protected function doExecute():void
		{
			super.doExecute();
			
			//Get the number of objects of the particular type, so we can name it usefully generically.
			var numObjectsOfType:uint = 0;
			for each (var object:ObjectInstance in gameState.objects)
			{
				if (object.className == event.objectAsset.className)
				numObjectsOfType++;
			}
			
			_objectInstance = gameState.createObject(event.objectAsset, event.x, event.y, gameState.lastGroupUsed);
		}
		
		override protected function undoExecute():void
		{
			super.undoExecute();
			
			gameState.deleteObject(_objectInstance);
		}
	}
}