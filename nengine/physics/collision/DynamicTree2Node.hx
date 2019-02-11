package nengine.physics.collision;
import nengine.math.*;
import nengine.physics.collision.shapes.AABB2;
import nengine.physics.collision.DynamicTree2Node;

class DynamicTree2Node
{
    public var aabb:AABB2;
    public var parent:DynamicTree2Node;
    public var child1:DynamicTree2Node;
    public var child2:DynamicTree2Node;
    public var height:Int;

    public function new() {
        this.aabb = new AABB2(new Vec2(), new Vec2());
    }

    public function isLeaf() {
        return child1 == null;
    }

}
