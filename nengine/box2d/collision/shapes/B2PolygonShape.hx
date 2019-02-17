package nengine.box2d.collision.shapes;
import nengine.box2d.common.math.B2Vec2;
import nengine.box2d.common.math.B2Mat22;
import nengine.box2d.common.math.B2Transform;

@:native("Box2D.Collision.Shapes.b2PolygonShape")
extern class B2PoligonShape extends B2Shape
{
    public var s_mat(default, never):B2Mat22;
}
