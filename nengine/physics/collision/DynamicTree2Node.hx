package nengine.physics.collision;
import nengine.math.*;
import nengine.physics.collision.shapes.AABB2;
import nengine.physics.collision.DynamicTree2Node;
import nengine.physics.dynamics.Fixture2;

class DynamicTree2Node
{
    private static var nodeId:Int = 0;
    public var aabb:AABB2;
    public var parent:DynamicTree2Node;
    public var child1:DynamicTree2Node;
    public var child2:DynamicTree2Node;
    public var height:Int;
    public var fixture:Fixture2;
    public var id(default, never) = nodeId++;
    public var childIndex:Int;

    public function new() {
        this.aabb = new AABB2(new Vec2(), new Vec2());
    }

    public function isLeaf() {
        return child1 == null;
    }

}
