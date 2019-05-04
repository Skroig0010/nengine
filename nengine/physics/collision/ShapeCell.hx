package nengine.physics.collision;
import ecs.Entity;
import nengine.physics.collision.shapes.*;
import nengine.math.*;

class ShapeCell
{
    public var shape:Shape;
    public var next:ShapeCell;
    public var prev:ShapeCell;
    public var parentId:Int;
    public var fatAABB:AABB2;

    public function new(shape:Shape, ?next:ShapeCell = null, ?prev:ShapeCell = null)
    {
        this.shape = shape;
        this.next = next;
        this.prev = prev;
    }
}
