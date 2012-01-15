package com.citrusengine.view.starlingview {

	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.textures.TextureAtlas;

	import flash.utils.Dictionary;

	/**
	 * The Animation Sequence class represents all object animations in one sprite sheet. You have to create your texture atlas in your state class.
	 * Example : var hero:Hero = new Hero("Hero", {x:400, width:60, height:130, view:new AnimationSequence(textureAtlas, ["walk", "duck", "idle", "jump"], "idle")});
	 * 
	 * @param textureAtlas : a TextureAtlas object with all your object's animations
	 * @param animations : an array with all your object's animations as a String
	 * @param firstAnimation : a string of your default animation at its creation
	 */
	public class AnimationSequence extends Sprite {

		private var _textureAtlas:TextureAtlas;
		private var _animations:Array;
		private var _mcSequences:Dictionary;
		private var _firstAnimation:String;

		public function AnimationSequence(textureAtlas:TextureAtlas, animations:Array, firstAnimation:String) {

			super();

			_textureAtlas = textureAtlas;

			_animations = animations;

			_mcSequences = new Dictionary();

			for each (var animation:String in animations)				
				_mcSequences[animation] = new MovieClip(_textureAtlas.getTextures(animation));
			
			_firstAnimation = firstAnimation;
			
			addChild(_mcSequences[_firstAnimation]);
			Starling.juggler.add(_mcSequences[_firstAnimation]);			
		}
		
		/**
		 * Called by StarlingArt, managed the MC's animations.
		 * @param animation : the MC's animation
		 * @param fps : the MC's fps
		 * @param animLoop : true if the MC is a loop
		 */
		public function changeAnimation(animation:String, fps:Number, animLoop:Boolean):void {
			
			removeChild(_mcSequences[_firstAnimation]);
			Starling.juggler.remove(_mcSequences[_firstAnimation]);
			
			addChild(_mcSequences[animation]);
			Starling.juggler.add(_mcSequences[animation]);
			_mcSequences[animation].fps = fps;
			_mcSequences[animation].loop = animLoop;
			
			_firstAnimation = animation;
		}
		
		public function destroy():void {
			
			removeChild(_mcSequences[_firstAnimation]);
			Starling.juggler.remove(_mcSequences[_firstAnimation]);
			
			for each (var animation : String in _animations)
				_mcSequences[animation].dispose();
			
			_textureAtlas.dispose();
		}
	}
}
