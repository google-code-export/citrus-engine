package commands 
{
	import events.UpdateObjectPropertyEvent;
	import flash.events.Event;
	import model.vo.GameState;
	import model.vo.ObjectInstanceParam;
	import model.vo.PropertyUpdateVO;
	import org.robotlegs.utilities.undoablecommand.UndoableCommand;
	
	public class UpdateObjectPropertyCommand extends UndoableCommand
	{
		[Inject]
		public var event:UpdateObjectPropertyEvent;
		
		[Inject]
		public var gameState:GameState;
		
		private var _oldPropertyValues:Array;
		
		override protected function doExecute():void
		{
			super.doExecute();
			
			_oldPropertyValues = new Array();
			for (var i:int = 0; i < event.updates.length; i++) 
			{
				var newUpdateVO:PropertyUpdateVO = event.updates[i];
				var property:ObjectInstanceParam = newUpdateVO.objectInstance.getParamByName(newUpdateVO.property);
				_oldPropertyValues.push(new PropertyUpdateVO(newUpdateVO.objectInstance, newUpdateVO.property, property.value));
				property.value = newUpdateVO.value;
				
				if (property.name == "group")
					gameState.lastGroupUsed = Number(property.value);
			}
			
			gameState.isFileOutOfDate = true;
			
			eventDispatcher.dispatchEvent(new UpdateObjectPropertyEvent(UpdateObjectPropertyEvent.OBJECT_PROPERTY_UPDATED, event.updates));
		}
		
		override protected function undoExecute():void
		{
			super.undoExecute();
			
			for (var i:int = 0; i < _oldPropertyValues.length; i++) 
			{
				var oldUpdateVO:PropertyUpdateVO = _oldPropertyValues[i];
				var property:ObjectInstanceParam = oldUpdateVO.objectInstance.getParamByName(oldUpdateVO.property);
				property.value = oldUpdateVO.value;
			}
			
			gameState.isFileOutOfDate = true;
			
			eventDispatcher.dispatchEvent(new UpdateObjectPropertyEvent(UpdateObjectPropertyEvent.OBJECT_PROPERTY_UPDATED, _oldPropertyValues));
		}
	}

}