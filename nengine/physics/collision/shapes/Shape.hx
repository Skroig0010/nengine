package nengine.physics.collision.shapes;
import nengine.components.Collider;
import nengine.math.*;

interface Shape
{
    public var type(default, never):ShapeType;
    public function computeAABB(transform:Transform2):AABB2;
    public function clone(collider:Collider):Shape;
    public var isSensor:Bool;
    public var cell(default, null):ShapeCell;
    // 比較用
    public var id(default, null):Int;
}

