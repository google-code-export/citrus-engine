package com.citrusengine.view {

	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.events.Event;

	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.objects.CitrusSprite;

	public class StarlingSpriteDebugArt extends DisplayObjectContainer {

		public function StarlingSpriteDebugArt() {
			
			super();

			addEventListener(Event.ADDED, handleAddedToParent);
		}

		private function handleAddedToParent(e:Event):void {			
		}

		public function initialize(object:CitrusObject):void {
			
			var citrusSprite:CitrusSprite = object as CitrusSprite;

			if (citrusSprite) {
				
				var quad:Quad = new Quad(citrusSprite.width, citrusSprite.height, 0x888888);
				addChild(quad);
			}
		}
	}
}