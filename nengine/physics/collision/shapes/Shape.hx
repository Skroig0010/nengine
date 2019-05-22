package nengine.physics.collision.shapes;
import nengine.math.*;
import nengine.components.RigidBody;
import nengine.physics.collision.ShapeCell;

interface Shape
{
    public var type(default, never):ShapeType;
    public var body:RigidBody; // RigidBody側で入れてくれる
    public var isSensor:Bool;
    public var cell(default, null):ShapeCell;
    public var friction:Float;
    public var restitution:Float;
    // 比較用
    public var id(default, null):Int;

    public function computeAABB(transform:Transform2):AABB2;
    public function computeMass(density:Float):MassData;
}
