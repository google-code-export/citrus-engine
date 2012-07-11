package com.citrusengine.physics {
	
	import com.citrusengine.objects.platformer.nape.Sensor;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.space.Space;
	
	/**
	 * @author Aymeric
	 */
	public class NapeContactListener {
		
		private var _space:Space;
		
		public function NapeContactListener(space:Space) {
			
			_space = space;
			
			_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, Sensor.SENSOR, CbType.ANY_BODY, onSensorInteractionBegin));
			_space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.SENSOR, Sensor.SENSOR, CbType.ANY_BODY, onSensorInteractionEnd));
		}
		
		public function destroy():void {
			
			_space.listeners.clear();
		}
		
		public function onSensorInteractionBegin(interactionCallback:InteractionCallback):void {
			interactionCallback.int1.castBody.userData.handleBeginContact(interactionCallback);
		}
		
		public function onSensorInteractionEnd(interactionCallback:InteractionCallback):void {
			interactionCallback.int1.castBody.userData.handleEndContact(interactionCallback);
		}
	}
}
