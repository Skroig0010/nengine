package nengine.physics.dynamics;
import nengine.physics.collision.shapes.Shape;

interface ContactFilter
{
    public function shouldCollide(shapeA:Shape, shapeB:Shape):Bool;
}

