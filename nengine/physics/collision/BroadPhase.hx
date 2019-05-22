package nengine.physics.collision;
import nengine.components.RigidBody;
import nengine.math.*;
import nengine.physics.collision.shapes.Shape; 

private typedef Pair = {
    shapeA:Shape,
    shapeB:Shape,
}
class BroadPhase
{
    private var quadTree:QuadTree;
    private var movedShapes = new List<Shape>();
    private var pairs = new Array<Pair>();
    public function new(quadTree:QuadTree)
    {
        this.quadTree = quadTree;
    }

    /* addBody分とaddShape分で二重にshapeを追加してしまっているのでこれは必要ない？
    public function addBody(body:RigidBody):Void
    {
        var transform = body.transform;
        for(shape in body.getShapesIterator())
        {
            addShape(shape, transform);
        }
    }

    public function removeBody(body:RigidBody):Void
    {
        for(shape in body.getShapesIterator())
        {
            removeShape(shape);
        }
    }*/

    public function addShape(shape:Shape, transform:Transform2):Void
    {
        quadTree.addShape(shape, transform);
        movedShapes.add(shape);
    }

    public function removeShape(shape:Shape):Void
    {
        quadTree.removeShape(shape);
        movedShapes.remove(shape);
    }

    public function moveShape(shape:Shape, transform:Transform2):Void
    {
        var buffer = quadTree.moveShape(shape, transform);
        if(buffer)movedShapes.add(shape);
    }

    public function touchShape(shape:Shape):Void
    {
        movedShapes.add(shape);
    }

    private function queryCallback(shapeA:Shape, shapeB:Shape):Void
    {
        if(shapeA == shapeB)
        {
            return;
        }

        pairs.push(if(shapeA.id < shapeB.id)
                {
                    {
                        shapeA:shapeA,
                        shapeB:shapeB
                    }
                }
                else
                {
                    {
                        shapeA:shapeB,
                        shapeB:shapeA
                    }
                });
    }

    public function updatePairs(callback:HitCallback):Void
    {
        for(shape in movedShapes)
        {
            quadTree.checkHit(shape, queryCallback);
        }

        movedShapes.clear();
        pairs.sort(comparePair);
        var length = pairs.length;
        var index = 0;
        while(index < length)
        {
            var primaryPair = pairs[index];
            callback(primaryPair.shapeA, primaryPair.shapeB);
            index++;

            // skip duplicate pairs
            while (index < length)
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
