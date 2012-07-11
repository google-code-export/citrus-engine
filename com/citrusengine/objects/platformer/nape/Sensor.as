package com.citrusengine.objects.platformer.nape {

	import com.citrusengine.objects.NapePhysicsObject;

	import nape.callbacks.CbType;
	import nape.dynamics.InteractionFilter;
	import nape.phys.BodyType;

	/**
	 * @author Aymeric
	 */
	public class Sensor extends NapePhysicsObject {

		public static const SENSOR:CbType = new CbType();

		public function Sensor(name:String, params:Object = null) {

			super(name, params);
		}

		override public function destroy():void {

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
	}
}
