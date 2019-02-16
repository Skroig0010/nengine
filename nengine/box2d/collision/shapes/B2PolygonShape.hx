package nengine.box2d.collision.shapes;
import nengine.box2d.common.math.B2Vec2;
import nengine.box2d.common.math.B2Mat22;
import nengine.box2d.common.math.B2Transform;

@:native("Box2D.Collision.Shapes.b2PolygonShape")
extern class B2PoligonShape extends B2Shape
{
    public var s_mat(default, never):B2Mat22;
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
