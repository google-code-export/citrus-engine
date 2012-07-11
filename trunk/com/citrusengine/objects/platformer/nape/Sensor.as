package com.citrusengine.objects.platformer.nape {

	import com.citrusengine.objects.NapePhysicsObject;

	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	import nape.phys.BodyType;
	
	import org.osflash.signals.Signal;

	/**
	 * @author Aymeric
	 */
	public class Sensor extends NapePhysicsObject {

		public static const SENSOR:CbType = new CbType();
		
		/**
		 * Dispatches on first contact with the sensor.
		 */
		public var onBeginContact:Signal;
		/**
		 * Dispatches when the object leaves the sensor.
		 */
		public var onEndContact:Signal;

		public function Sensor(name:String, params:Object = null) {

			super(name, params);
			
			onBeginContact = new Signal(InteractionCallback);
			onEndContact = new Signal(InteractionCallback);
		}

		override public function destroy():void {
			
			onBeginContact.removeAll();
			onEndContact.removeAll();

			super.destroy();
		}

		override public function update(timeDelta:Number):void {

			super.update(timeDelta);
		}

		override protected function defineBody():void {

			_bodyType = BodyType.STATIC;
		}

		override protected function createShape():void {

			super.createShape();
			
			_body.setShapeFilters(new InteractionFilter(0, 0, 1, 1, 0, 0));
		}
		
		override protected function createConstraint():void {
			
			_body.space = _nape.space;			
			_body.cbTypes.add(SENSOR);
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void {
			onBeginContact.dispatch(callback);
		}
		
		override public function handleEndContact(callback:InteractionCallback):void {
			onEndContact.dispatch(callback);
		}
	}
}
