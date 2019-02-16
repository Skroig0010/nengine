package nengine.box2d.collision.shapes;
import nengine.box2d.common.math.B2Transform;
import nengine.box2d.common.math.B2Vec2;

@:native("Box2D.Collision.Shapes.b2Shape")
extern class B2Shape
{
      public var e_unknownShape(default, never):Int;
      public var e_circleShape(default, never):Int;
      public var e_polygonShape(default, never):Int;
      public var e_edgeShape(default, never):Int;
      public var e_shapeTypeCount(default, never):Int;
      public var e_hitCollide(default, never):Int;
      public var e_missCollide(default, never):Int;
      public var e_startsInsideCollide(default, never):Int;

      public function Copy():B2Shape;
      public function Set(other:B2Shape):Void;
      public function GetType():Int;
      public function TestPoint(xf:B2Transform, p:B2Vec2):Bool;
      // public function RayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool;
      // public function ComputeAABB(aabb:B2AABB, xf:B2Transform):Bool;
      // public function ComputeMass(massData:B2MassData, density:Float):Void;
      public function ComputeSubmergedArea(normal:B2Vec2, offset:Float, xf:B2Transform, c:B2Vec2):Float;
      public function TestOverlap(shape1:B2Shape, transform1:B2Transform, shape2:B2Shape, transform2:B2Transform):Bool;
}
