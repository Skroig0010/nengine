package nengine.physics.collision.shapes;
import nengine.math.*;
import nengine.components.RigidBody;
import nengine.physics.collision.ShapeCell;

interface Shape
{
    public function computeAABB(transform:Transform2):AABB2;
    public var body:RigidBody;
    public var cell(default, null):ShapeCell;
}
