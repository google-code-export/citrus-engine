package com.citrusengine.view.starlingview {
	
	import Box2DAS.Dynamics.b2DebugDraw;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;

	import com.citrusengine.physics.Box2D;

	import flash.display.BitmapData;

	/**
	 * This displays Box2D's debug graphics. It does so properly through Citrus Engine's view manager. Box2D by default
	 * sets visible to false, so you'll need to set the Box2D object's visible property to true in order to see the debug graphics. 
	 */
	public class Box2DDebugArt extends Sprite {

		private var _box2D:Box2D;
		private var _debugDrawer:b2DebugDraw;
		
		private var _bmd:BitmapData;
		
		private var _texture:Texture;
		private var _box2DView:Image;

		public function Box2DDebugArt() {
			addEventListener(Event.ADDED, handleAddedToParent);
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			addEventListener(Event.REMOVED, destroy);
		}

		private function handleAddedToParent(evt:Event):void {
			removeEventListener(Event.ADDED, handleAddedToParent);

			_box2D = StarlingArt(parent).citrusObject as Box2D;

			_debugDrawer = new b2DebugDraw();
			
			//TODO : think of Big TextureAtlas
			
			_bmd = new BitmapData(1648, 350, true, 0);
			
			_texture = Texture.fromBitmapData(_bmd);
			_box2DView = new Image(_texture);
			
			addChild(_box2DView);

			_debugDrawer.world = _box2D.world;
			_debugDrawer.scale = _box2D.scale;
		}

		private function destroy(evt:Event):void {
			removeEventListener(Event.ADDED, handleAddedToParent);
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			removeEventListener(Event.REMOVED, destroy);
			
			_box2DView.texture.dispose();
		}

		private function handleEnterFrame(evt:Event):void {
			
			_debugDrawer.Draw();
			
			//TODO : enhance performance
			
			_bmd.fillRect(_bmd.rect, 0);
			_bmd.draw(_debugDrawer);
			
			_box2DView.texture.dispose();
			_box2DView.texture = Texture.fromBitmapData(_bmd);
		}
	}
}