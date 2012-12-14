package {

	import citrus.objects.NapePhysicsObject;

	import nape.geom.Vec2;
	import nape.phys.Material;
	import nape.shape.Polygon;

	/**
	 * @author Aymeric
	 * <p>This is a class created by the software <a href="http://www.physicseditor.de/">PhysicsEditor</a></p>
	 * <p>Launch PhysicsEditor, select the CitrusEngine template, upload your png picture, set polygons and export.</p>
	 * <p>Be careful, the anchor point is not the localCOM but object's center!</p>
	 * @param peObject the name of the png file
	 */
    public class PhysicsEditorObjects extends NapePhysicsObject {
		
		[Inspectable(defaultValue="")]
		public var peObject:String = "";

		private var _tab:Array;

		public function PhysicsEditorObjects(name:String, params:Object = null) {

			super(name, params);
		}

		override public function destroy():void {

			super.destroy();
		}

		override public function update(timeDelta:Number):void {

			super.update(timeDelta);
		}

		override protected function createShape():void {

			_createVertices();

			for (var i:uint = 0; i < _tab.length; ++i) {

				var polygonShape:Polygon = new Polygon(_tab[i]);
				_shape = polygonShape;
				_body.shapes.add(_shape);
			}

			_body.translateShapes(Vec2.weak(-_body.bounds.width * 0.5, -_body.bounds.height * 0.5));

			_body.position.x += _body.bounds.width * 0.5;
			_body.position.y += _body.bounds.height * 0.5;
		}

		override protected function createMaterial():void {
			
			_material = new Material(_getElasticity(), _getDynamicFriction(), _getStaticFriction(), _getDensity(), _getRollingFriction());
		}
		
        protected function _createVertices():void {
			
			_tab = [];
			var vertices:Array = [];

			switch (peObject) {
				{% for body in bodies %}
				case "{{body.name}}":
					{% for fixture in body.fixtures %}{% for polygon in fixture.polygons %}						
			        {% for point in polygon %}vertices.push(Vec2.weak({{point.x}}, {{point.y}}));
					{% endfor %}
					_tab.push(vertices);{% if not forloop.last %}
					vertices = [];{% endif %}
					{% endfor %}{% endfor %}
					break;
			{% endfor %}
			}
		}

		protected function _getElasticity():Number {

			switch (peObject) {
				{% for body in bodies %}
				case "{{body.name}}":
					{% for fixture in body.fixtures %}return {{fixture.elasticity}};{% endfor %}
			{% endfor %}
			}

			return 0.2;
		}
		
		protected function _getDynamicFriction():Number {
			
			switch (peObject) {
				{% for body in bodies %}
				case "{{body.name}}":
					{% for fixture in body.fixtures %}return {{fixture.dynamicFriction}};{% endfor %}
			{% endfor %}
			}

			return 1;
		}

		protected function _getStaticFriction():Number {
			
			switch (peObject) {
				{% for body in bodies %}
				case "{{body.name}}":
					{% for fixture in body.fixtures %}return {{fixture.staticFriction}};{% endfor %}
			{% endfor %}
			}

			return 1;
		}
		
		protected function _getDensity():Number {
			
			switch (peObject) {
				{% for body in bodies %}
				case "{{body.name}}":
					{% for fixture in body.fixtures %}return {{fixture.density}};{% endfor %}
			{% endfor %}
			}

			return 1;
		}

		protected function _getRollingFriction():Number {
			
			switch (peObject) {
				{% for body in bodies %}
				case "{{body.name}}":
					{% for fixture in body.fixtures %}return {{fixture.rollingFriction}};{% endfor %}
			{% endfor %}
			}

			return 0;
		}
	}
}
