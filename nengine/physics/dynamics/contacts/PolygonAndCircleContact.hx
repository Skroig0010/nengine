package nengine.physics.dynamics.contacts;
import nengine.math.*;
import nengine.physics.collision.CollideCircle;
import nengine.physics.collision.Manifold;
import nengine.physics.collision.shapes.*;

class PolygonAndCircleContact extends Contact
{
    private function new() { }

    public static function create():Contact
    {
        return new PolygonAndCircleContact();
    }

    private override function evaluate(transformA:Transform2, transformB:Transform2):Manifold
    {
        return CollideCircle.collidePolygonAndCircle(cast (shapeA, PolygonShape), transformA, cast (shapeB, CircleShape), transformB);
    }
}
