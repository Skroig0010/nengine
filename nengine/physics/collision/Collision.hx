package nengine.physics.collision;
import ecs.Entity;
import nengine.components.*;
import nengine.components.shapes.*;
import nengine.math.*;

class Collision
{
    public static function collideCircles(
            circleA:CircleShape, transformA:Transform2, 
            circleB:CircleShape, transformB:Transform2):Manifold
    {
        var pointA = transformA * circleA.position;
        var pointB = transformB * circleB.position;
        var distSq = (pointB - pointA).lengthSq();
        var radius = circleA.radius + circleB.radius;

        if(distSq > radius * radius)
        {
            return new Manifold(ManifoldType.Circles, [], new Vec2(), new Vec2());
        }

        return new Manifold(ManifoldType.Circles, [circleB.position.copy()], new Vec2(), circleA.position.copy());
    }
}
