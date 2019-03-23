package nengine.physics.collision;
import nengine.components.Collider;
import nengine.math.AABB2;
import nengine.physics.collision.shapes.Shape;

// Box2dでいうproxy
class ShapeCell
{
    public var shape:Shape;
    public var collider:Collider;

    public var next:ShapeCell;
    public var prev:ShapeCell;
    public var parentId:Int;
    public var fatAABB:AABB2;

    public function new(shape:Shape, collider:Collider, ?parentId:Int = 0, ?next:ShapeCell = null, ?prev:ShapeCell = null)
    {
        this.shape = shape;
        this.collider = collider;
        this.parentId = parentId;
        this.next = next;
        this.prev = prev;
    }
}
