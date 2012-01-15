package com.citrusengine.view.starlingview {

	import Box2DAS.Dynamics.b2DebugDraw;

	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.extensions.textureAtlas.DynamicAtlas;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import com.citrusengine.view.ISpriteView;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	/**
	 * This is the class that all art objects use for the StarlingView state view. If you are using the StarlingView (as opposed to the blitting view, for instance),
	 * then all your graphics will be an instance of this class. There are 2 ways to manage MovieClip :
	 * - specify a "object.swf" in the view property of your object's creation.
	 * - add an AnimationSequence to your view property of your object's creation, see the AnimationSequence for more informations about it.
	 * The AnimationSequence is more optimized than the .swf which creates textures "on the fly" thanks to the DynamicAtlas class.
	 * 
	 * This class does the following things:
	 * 
	 * 1) Creates the appropriate graphic depending on your CitrusObject's view property (loader, sprite, or bitmap), and loads it if it is a non-embedded graphic.
	 * 2) Aligns the graphic with the appropriate registration (topLeft or center).
	 * 3) Calls the MovieClip's appropriate frame label based on the CitrusObject's animation property.
	 * 4) Updates the graphic's properties to be in-synch with the CitrusObject's properties once per frame.
	 * 
	 * These objects will be created by the Citrus Engine's StarlingView, so you should never make them yourself. When you use state.getArt() to gain access to your game's graphics
	 * (for adding click events, for instance), you will get an instance of this object. It extends Sprite, so you can do all the expected stuff with it, 
	 * such as add click listeners, change the alpha, etc.
	 **/
	public class StarlingArt extends Sprite {

		public var content:DisplayObject;

		public var loader:Loader;

		// properties :
		
		// determines animations playing in loop. You can add one in your state class : StarlingArt.setLoopAnimations(["walk", "climb"]);
		private static var _loopAnimation:Dictionary = new Dictionary();
		
		private var _citrusObject:ISpriteView;
		private var _registration:String;
		private var _view:*;
		private var _animation:String;
		private var _group:int;
		
		// fps for this MovieClip, it can be different between objects, to set it : view.getArt(myHero).fpsMC = 25; 
		private var _fpsMC:uint = 30;

		private var _texture:Texture;
		private var _textureAtlas:TextureAtlas;

		public function StarlingArt(object:ISpriteView) {

			_citrusObject = object;
			
			if (_loopAnimation["walk"] != true) {
				_loopAnimation["walk"] = true;
			}
		}

		public function destroy():void {

			if (content is MovieClip) {
				Starling.juggler.remove(content as MovieClip);
				_textureAtlas.dispose();
				content.dispose();
			
			} else if (content is AnimationSequence) {
				
				(content as AnimationSequence).destroy();
				content.dispose();
				
			} else if (content is Image) {
				_texture.dispose();
				content.dispose();
			}

		}
		
		/**
		 * Add a loop animation to the Dictionnary.
		 * @param tab an array with all the loop animation names.
		 */
		static public function setLoopAnimations(tab:Array):void {
			
			for each (var animation:String in tab) {
				_loopAnimation[animation] = true;
			}
		}
		
		static public function get loopAnimation():Dictionary {
			return _loopAnimation;
		}

		public function get registration():String {
			return _registration;
		}

		public function set registration(value:String):void {

			if (_registration == value || !content)
				return;

			_registration = value;

			if (_registration == "topLeft") {
				content.x = 0;
				content.y = 0;
			} else if (_registration == "center") {
				content.x = -content.width / 2;
				content.y = -content.height / 2;
			}
		}

		public function get view():* {
			return _view;
		}

		public function set view(value:*):void {

			if (_view == value)
				return;

			_view = value;

			if (_view) {
				if (_view is String) {
					// view property is a path to an image?
					var classString:String = _view;
					var suffix:String = classString.substring(classString.length - 4).toLowerCase();
					if (suffix == ".swf" || suffix == ".png" || suffix == ".gif" || suffix == ".jpg") {
						loader = new Loader();
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleContentLoaded);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleContentIOError);
						loader.load(new URLRequest(classString));
					}
					// view property is a fully qualified class name in string form. 
					else {
						var artClass:Class = getDefinitionByName(classString) as Class;
						content = new artClass();
						addChild(content);
					}
				} else if (_view is Class) {
					// view property is a class reference
					content = new citrusObject.view();
					addChild(content);

				} else if (_view is DisplayObject) {
					// view property is a Display Object reference
					content = _view;
					addChild(content);
				} else {
					throw new Error("SpriteArt doesn't know how to create a graphic object from the provided CitrusObject " + citrusObject);
					return;
				}

				if (content && content.hasOwnProperty("initialize"))
					content["initialize"](_citrusObject);
			}
		}

		public function get animation():String {
			return _animation;
		}

		public function set animation(value:String):void {

			if (_animation == value)
				return;

			_animation = value;
			
			if (_animation != null && _animation != "") {
				
				var animLoop:Boolean = _loopAnimation[_animation];
				
				if (content is MovieClip)
					(content as MovieClip).changeTextures(_textureAtlas.getTextures(_animation), _fpsMC, animLoop);
				
				if (content is AnimationSequence)
					(content as AnimationSequence).changeAnimation(_animation, _fpsMC, animLoop);
			}
		}

		public function get group():int {
			return _group;
		}

		public function set group(value:int):void {
			_group = value;
		}

		public function get fpsMC():uint {
			return _fpsMC;
		}

		public function set fpsMC(fpsMC:uint):void {
			_fpsMC = fpsMC;
		}

		public function get citrusObject():ISpriteView {
			return _citrusObject;
		}

		public function update(stateView:StarlingView):void {

			if (content is Box2DDebugArt) {

				// Box2D view is not on the Starling display list, but on the classical flash display list.
				// So we need to move its view here, not in the StarlingView.

				var box2dDebugArt:b2DebugDraw = (Starling.current.nativeStage.getChildAt(1) as b2DebugDraw);

				if (stateView.cameraTarget) {

					var diffX:Number = (-stateView.cameraTarget.x + stateView.cameraOffset.x) - box2dDebugArt.x;
					var diffY:Number = (-stateView.cameraTarget.y + stateView.cameraOffset.y) - box2dDebugArt.y;
					var velocityX:Number = diffX * stateView.cameraEasing.x;
					var velocityY:Number = diffY * stateView.cameraEasing.y;
					box2dDebugArt.x += velocityX;
					box2dDebugArt.y += velocityY;

					// Constrain to camera bounds
					if (stateView.cameraBounds) {
						if (-box2dDebugArt.x <= stateView.cameraBounds.left || stateView.cameraBounds.width < stateView.cameraLensWidth)
							box2dDebugArt.x = -stateView.cameraBounds.left;
						else if (-box2dDebugArt.x + stateView.cameraLensWidth >= stateView.cameraBounds.right)
							box2dDebugArt.x = -stateView.cameraBounds.right + stateView.cameraLensWidth;

						if (-box2dDebugArt.y <= stateView.cameraBounds.top || stateView.cameraBounds.height < stateView.cameraLensHeight)
							box2dDebugArt.y = -stateView.cameraBounds.top;
						else if (-box2dDebugArt.y + stateView.cameraLensHeight >= stateView.cameraBounds.bottom)
							box2dDebugArt.y = -stateView.cameraBounds.bottom + stateView.cameraLensHeight;
					}
				}

				box2dDebugArt.visible = _citrusObject.visible;

			} else {

				// The position = object position + (camera position * inverse parallax)
				x = _citrusObject.x + (-stateView.viewRoot.x * (1 - _citrusObject.parallax)) + _citrusObject.offsetX;
				y = _citrusObject.y + (-stateView.viewRoot.y * (1 - _citrusObject.parallax)) + _citrusObject.offsetY;
				visible = _citrusObject.visible;
				rotation = _citrusObject.rotation;
				scaleX = _citrusObject.inverted ? -1 : 1;
				registration = _citrusObject.registration;
				view = _citrusObject.view;
				animation = _citrusObject.animation;
				group = _citrusObject.group;
			}
		}

		private function handleContentLoaded(evt:Event):void {

			if (evt.target.loader.content is flash.display.MovieClip) {

				_textureAtlas = DynamicAtlas.fromMovieClipContainer(evt.target.loader.content, 1, 0, true, true);
				content = new MovieClip(_textureAtlas.getTextures(animation), _fpsMC);
				Starling.juggler.add(content as MovieClip);
			}

			if (evt.target.loader.content is Bitmap) {
				
				_texture = Texture.fromBitmap(evt.target.loader.content);
				content = new Image(_texture);
			}

			addChild(content);
		}

		private function handleContentIOError(evt:IOErrorEvent):void {
			throw new Error(evt.text);
		}

	}
}
