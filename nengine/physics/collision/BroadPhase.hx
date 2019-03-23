package nengine.physics.collision;
import nengine.components.Collider;
import nengine.math.*;
import nengine.physics.collision.shapes.Shape; 

private typedef Pair = {
    colliderA:Collider,
    shapeA:Shape,
    colliderB:Collider,
    shapeB:Shape,
}
class BroadPhase
{
    public static var aabbExtension(default, never) = 0.1;

    private var quadTree:QuadTree;
    private var movedColliders = new Array<Collider>();
    public function new(area:AABB2, defaultColliderSize:AABB2)
    {
        var areaSize = area.lowerBound - area.upperBound;
        var colliderSize = defaultColliderSize.lowerBound - defaultColliderSize.upperBound;
        var divX = areaSize.x / (colliderSize.x * 2);
        var divY = areaSize.y / (colliderSize.y * 2);
        var div = Std.int(Math.min(divX, divY));

        // calculate tree level
        var level = 0;
        while(div != 0)
        {
            level++;
            div >>= 1;
        }
        level--;

        quadTree = new QuadTree(level, area);
    }

    public function addShapes(shapes:Array<Shape>, collider:Collider):Void
    {
        collider.addShapes(quadTree, shapes);
        movedColliders.push(collider);
    }

    public function removeShapes(shapes:Array<Shape>, collider:Collider):Void
    {
        collider.removeShapes(quadTree, shapes);
        movedColliders.remove(collider);
    }

    public function addColliderToTree(collider:Collider):Void
    {
        collider.addToTree(quadTree);
        movedColliders.push(collider);
    }

    public function removeColliderFromTree(collider:Collider):Void
    {
        collider.removeFromTree(quadTree);
        movedColliders.remove(collider);
    }

    public function moveCollider(collider:Collider):Void
    {
        movedColliders.push(collider);
    }


    public function updatePairs(callback:HitCallBack):Void
    {
        if(movedColliders.length == 0) return;
        var pairs = new Array<Pair>();
        var hit:HitCallBack = (colliderA:Collider, shapeA:Shape, colliderB:Collider, shapeB:Shape)->{
            if(shapeA.id < shapeB.id)
            {
                pairs.push({colliderA:colliderA, shapeA:shapeA, colliderB:colliderB, shapeB:shapeB});
            }
            else
            {
                pairs.push({colliderA:colliderB, shapeA:shapeB, colliderB:colliderA, shapeB:shapeA});
            }
        }
        // 移動したColliderの衝突判定
        for(collider in movedColliders)
        {
            collider.updateShapes(quadTree, hit);
        }

        movedColliders = new Array<Collider>();
        pairs.sort(comparePair);

        var length = pairs.length;
        var index = 0;
        while(index < length)
        {
            var primaryPair = pairs[index];
            callback(primaryPair.colliderA, primaryPair.shapeA, primaryPair.colliderB, primaryPair.shapeB);
            index++;

            // remove duplicate pair
            while(index < length)
            {
                var pair = pairs[index];
                if(pair.shapeA.id != primaryPair.shapeA.id || pair.shapeB.id != primaryPair.shapeB.id)
                {
                    break;
                }
                index++;
            }
        }
    }

    private function comparePair(pairA:Pair, pairB:Pair):Int
    {
        var diff = pairA.shapeA.id - pairB.shapeA.id;
        return if(diff != 0) diff else pairA.shapeB.id - pairB.shapeB.id;
    }
}
