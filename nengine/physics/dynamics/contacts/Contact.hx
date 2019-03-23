package nengine.physics.dynamics.contacts;
import nengine.components.Collider;
import nengine.components.Transform;
import nengine.math.*;
import nengine.physics.collision.shapes.Shape;
import nengine.physics.collision.ContactEdge;
import nengine.physics.collision.Manifold;
using nengine.physics.collision.ManifoldFunction;

class Contact
{
    public var manifold(default, null):Manifold;
    public var shapeA:Shape;
    public var shapeB:Shape;
    public var colliderA:Collider;
    public var colliderB:Collider;
    public var touching = false;
    public var prev:Contact;
    public var next:Contact;
    public var nodeA:ContactEdge;
    public var nodeB:ContactEdge;

    public static function create(colliderA:Collider, shapeA:Shape, colliderB:Collider, shapeB:Shape):Contact
    {
        var contact = switch([shapeA.type, shapeB.type])
        {
            case [Circle, Circle]:
                CircleContact.create();
            case [Polygon, Polygon]:
                PolygonContact.create();
            case [Circle, Polygon]:
                PolygonAndCircleContact.create();
            case [Polygon, Circle]:
                PolygonAndCircleContact.create();
        }
        contact.shapeA = shapeA;
        contact.shapeB = shapeB;
        contact.colliderA = colliderA;
        contact.colliderB = colliderB;

        return contact;
    }

    public function update(listener:ContactListener):Void
    {
        var oldManifold = manifold;
        var touching = false;
        var wasTouching = this.touching;
        var sensor = shapeA.isSensor || shapeB.isSensor;
        var transformA = cast(colliderA.entity.getComponent(Transform.componentName), Transform).global;
        var transformB = cast(colliderB.entity.getComponent(Transform.componentName), Transform).global;

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

        this.touching = touching;

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
