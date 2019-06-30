package nengine.physics.dynamics.contacts;
import nengine.math.*;
import nengine.components.Transform;
import nengine.physics.collision.Manifold;
import nengine.physics.collision.shapes.Shape;
import nengine.physics.dynamics.contacts.ContactEdge;
using nengine.physics.collision.ManifoldFunction;

class Contact
{
    public var manifold(default, null) = Manifold.None;
    public var shapeA:Shape;
    public var shapeB:Shape;
    public var prev:Contact;
    public var next:Contact;
    public var nodeA = new ContactEdge();
    public var nodeB = new ContactEdge();
    public var friction:Float;
    public var restitution:Float;
    public var tangentSpeed:Float = 0;

    // flags
    public var islandFlag:Bool = false;
    public var touchingFlag:Bool = false;
    public var enabledFlag:Bool = false;
    public var filterFlag:Bool = false;
    public var bulletHitFlag:Bool = false;
    public var toiFlag:Bool = false;

    public static function create(shapeA:Shape, shapeB:Shape):Contact
    {
        var primary = true;
        var contact = switch([shapeA.type, shapeB.type])
        {
            case [Circle, Circle]:
                CircleContact.create();
            case [Polygon, Polygon]:
                PolygonContact.create();
            case [Circle, Polygon]:
                primary = false;
                PolygonAndCircleContact.create();
            case [Polygon, Circle]:
                PolygonAndCircleContact.create();
        }
        if(primary){
            contact.shapeA = shapeA;
            contact.shapeB = shapeB;
        }else{
            contact.shapeA = shapeB;
            contact.shapeB = shapeA;
        }
        contact.friction = mixFriction(shapeA.friction, shapeB.friction);
        contact.restitution = mixRestitution(shapeA.restitution, shapeB.restitution);

        return contact;
    }

    private static inline function mixFriction(frictionA:Float, frictionB:Float):Float
    {
        return Math.sqrt(frictionA * frictionB);
    }

    private static inline function mixRestitution(restitutionA:Float, restitutionB:Float):Float
    {
        return if(restitutionA > restitutionB) restitutionA else restitutionB;
    }

    public function update(listener:ContactListener):Void
    {
        var oldManifold = manifold;
        var touching = false;
        var wasTouching = touchingFlag;
        var sensor = shapeA.isSensor || shapeB.isSensor;
        var transformA = shapeA.body.transform;
        var transformB = shapeB.body.transform;

        if(sensor)
        {
            touching = !Type.enumEq(Manifold.None, evaluate(transformA, transformB));
            manifold = Manifold.None;
        }
        else
        {
            manifold = evaluate(transformA, transformB);
            touching = !Type.enumEq(Manifold.None, manifold);
            manifold.mapPoints((point)-> {
                point.normalImpulse = 0;
                point.tangentImpulse = 0;

                oldManifold.mapPoints((oldPoint)-> {
                    if(point.isSame(oldPoint))
                    {
                        point.normalImpulse = oldPoint.normalImpulse;
                        point.tangentImpulse = oldPoint.tangentImpulse;
                    }
                });
            });
        }

        touchingFlag = touching;

        if(!wasTouching && touching && listener != null)
        {
            listener.beginContact(this);
        }

        if(wasTouching && !touching && listener != null)
        {
            listener.endContact(this);
        }

        if(!sensor && touching && listener != null)
        {
            listener.preSolve(this, oldManifold);
        }
    }

    private function evaluate(transformA:Transform2, transformB:Transform2):Manifold
    {
        throw "this function should be overridden";
    }

}
