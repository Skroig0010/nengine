package nengine.physics.dynamics.contacts;
import nengine.math.*;
import nengine.physics.collision.CollideCircle;
import nengine.physics.collision.Manifold;
import nengine.physics.collision.shapes.*;

class CircleContact extends Contact
{
    private function new() { }

    public static function create():Contact
    {
        return new CircleContact();
    }

    private override function evaluate(transformA:Transform2, transformB:Transform2):Manifold
    {
        return CollideCircle.collideCircles(cast (shapeA, CircleShape), transformA, cast (shapeB, CircleShape), transformB);
    }
}
