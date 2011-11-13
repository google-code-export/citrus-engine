package {

    import Box2DAS.Collision.Shapes.b2PolygonShape;
	import Box2DAS.Common.V2;

	import com.citrusengine.objects.PhysicsObject;

	/**
	 * @author Aymeric
	 * <p>This is a class created by the software http://www.physicseditor.de/</p>
	 * <p>Just select the CitrusEngine template, upload your png picture, set polygons and export.</p>
	 * <p>Be careful, the registration point is topLeft !</p>
	 * @param peObject : the name of the png file
	 */
    public class PhysicsEditorObjects extends PhysicsObject {
		
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

		override protected function defineFixture():void {
			
			super.defineFixture();
			
			_createVertices();

			_fixtureDef.density = _getDensity();
			_fixtureDef.friction = _getFriction();
			_fixtureDef.restitution = _getRestitution();
			
			for (var i:uint = 0; i < _tab.length; ++i) {
				var polygonShape:b2PolygonShape = new b2PolygonShape();
				polygonShape.Set(_tab[i]);
				_fixtureDef.shape = polygonShape;

				body.CreateFixture(_fixtureDef);
			}
		}
		
        protected function _createVertices():void {
			
			_tab = [];
			var vertices:Vector.<V2> = new Vector.<V2>();

			switch (peObject) {
				{% for body in bodies %}
				case "{{body.name}}":
					{% for fixture in body.fixtures %}{% for polygon in fixture.polygons %}						
			        {% for point in polygon %}vertices.push(new V2({{point.x}}/_box2D.scale, {{point.y}}/_box2D.scale));
					{% endfor %}
					_tab.push(vertices);{% if not forloop.last %}
					vertices = new Vector.<V2>();{% endif %}
					{% endfor %}{% endfor %}
					break;
			{% endfor %}
			}
		}

		protected function _getDensity():Number {

			switch (peObject) {
				{% for body in bodies %}
				case "{{body.name}}":
					{% for fixture in body.fixtures %}return {{fixture.density}};{% endfor %}
					break;
			{% endfor %}
			}

			return 1;
		}
		
		protected function _getFriction():Number {
			
			switch (peObject) {
				{% for body in bodies %}
				case "{{body.name}}":
					{% for fixture in body.fixtures %}return {{fixture.friction}};{% endfor %}
					break;
			{% endfor %}
			}

			return 0.6;
		}
		
		protected function _getRestitution():Number {
			
			switch (peObject) {
				{% for body in bodies %}
				case "{{body.name}}":
					{% for fixture in body.fixtures %}return {{fixture.restitution}};{% endfor %}
					break;
			{% endfor %}
			}

			return 0.3;
		}
	}
}
