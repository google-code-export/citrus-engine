package com.citrusengine.objects.platformer.simple {

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.objects.CitrusSprite;

	/**
	 * An object that will be moved away from overlapping during a collision (probably your hero or something else that moves).
	 */
	public class DynamicObject extends CitrusSprite {
		
		public var gravity:Number = 20;
		
		protected var _ce:CitrusEngine;

		public function DynamicObject(name:String, params:Object = null) {
			
			super(name, params);
			
			_ce = CitrusEngine.getInstance();
			
			velocity.y = gravity;
		}
	}
}
