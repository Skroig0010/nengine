package nengine.physics.collision.shapes;
import ecs.Component;
import ecs.Entity;
import nengine.math.*;

interface Shape2
{
    public var type(default, never):Shape2Type;
    public var radius:Float;
    public var childCount(get, never):Int;

    public function testPoint(transform:Transform2, point:Vec2):Bool;
    public function computeMass(density:Float):MassData;
    public function computeAABB(transform:Transform2):AABB2;
}
