package nengine.physics.collision;
import nengine.components.Collider;
import nengine.physics.collision.shapes.Shape;

typedef HitCallBack = Collider->Shape->Collider->Shape->Void;
