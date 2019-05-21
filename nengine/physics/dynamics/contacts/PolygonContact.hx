package nengine.physics.dynamics.contacts;
import nengine.math.*;
import nengine.physics.collision.Collision;
import nengine.physics.collision.Manifold;
import nengine.physics.collision.shapes.*;

class PolygonContact extends Contact
{
    private function new() { }

    public static function create():Contact
    {
        return new PolygonContact();
    }

    private override function evaluate(transformA:Transform2, transformB:Transform2):Manifold
    {
        return Collision.collidePolygons(cast (shapeA, PolygonShape), transformA, cast (shapeB, PolygonShape), transformB);
    }
}
