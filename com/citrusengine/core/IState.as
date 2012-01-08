package com.citrusengine.core {

	import com.citrusengine.view.CitrusView;
	
	/**
	 * Take a look on the 2 respective states to have some information on the functions.
	 */
	public interface IState {
		
		function destroy():void;
		
		function get view():CitrusView;
		
		function initialize():void;
		
		function update(timeDelta:Number):void;
		
		function add(object:CitrusObject):CitrusObject;
		
		function remove(object:CitrusObject):void;
		
		function getObjectByName(name:String):CitrusObject;
		
		function getFirstObjectByType(type:Class):CitrusObject;
		
		function getObjectsByType(type:Class):Vector.<CitrusObject>;
	}
}
