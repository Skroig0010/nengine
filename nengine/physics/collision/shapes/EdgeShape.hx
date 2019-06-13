package nengine.physics.collision.shapes;
import nengine.math.*;
import nengine.physics.collision.ShapeCell;
import nengine.components.RigidBody;
/*
class EdgeShape implements Shape
{
    public var type(default, never) = ShapeType.Edge;
    public var body:RigidBody; // RigidBody側で入れてくれる
    public var isSensor:Bool;
    public var cell(default, null):ShapeCell;
    public var friction:Float;
    public var restitution:Float;
    public var density:Float;
    public var radius:Float = 0.05;
    // 比較用
    public var id(default, null):Int;

    public var vertex1:Vec2, vertex2:Vec2;

    // optional
    public var vertex0:Option<Vec2>, vertex3:Option<Vec2>;

    public function new(vertex0:Vec2, vertex1:Vec2, ?vertex0:Vec2, ?vertex3:Vec2)
    {
        this.vertex1 = vertex1;
        this.vertex2 = vertex2;
        this.vertex0 = if(vertex0 != null) Some(vertex0) else None;
        this.vertex3 = if(vertex3 != null) Some(vertex3) else None;
    }

    public function computeAABB(transform:Transform2):AABB2
    {
        var v1 = transform * vertex1;
        var v2 = transform * vertex2;

        var upper = Math2.min(v1, v2);
        var lower = Math2.max(v1, v2);

        var r = new Vec2(radius, radius);

        return new AABB2(upper - r, lower - r);
    }
    public function computeMass():MassData
    {
        var massData = new MassData();
        massData.mass = 0.0;
        massData.center = 0.5 * (vertex1 + vertex2);
        massData.inertia = 0.0;

        return massData;
    }
}
*/
