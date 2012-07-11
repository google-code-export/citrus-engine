package com.citrusengine.objects.platformer.nape {

	import com.citrusengine.objects.NapePhysicsObject;
	
	import nape.phys.BodyType;

	/**
	 * @author Aymeric
	 */
	public class Platform extends NapePhysicsObject {
		
		private var _oneWay:Boolean = false;

		public function Platform(name:String, params:Object = null) {
			
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
	}
}
