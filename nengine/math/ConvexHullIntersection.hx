package nengine.math;
import nengine.physics.collision.Collision;

@:deprecated
class ConvexHullIntersection
{
    public static function intersectConvexHull(convA:ConvexHull2, convB:ConvexHull2):Option<ConvexHull2>
    {
        var vsA = convA.vertices;
        var vsB = convB.vertices;
        var indexA = 0;
        var indexB = 0;
        var sizeA = vsA.length;
        var sizeB = vsB.length;
        var advanceA = 0;
        var advanceB = 0;
        var kind = Kind.Unknown;

        var resultVertices = new Array<Vec2>();

        do
        {
            var prevIndexA = (indexA - 1 + sizeA) % sizeA;
            var prevIndexB = (indexB - 1 + sizeB) % sizeB;

            var cross = (vsA[indexA] - vsA[prevIndexA]).cross(vsB[indexB] - vsB[prevIndexB]);
            var aInHB = (vsA[prevIndexA] - vsB[indexB]).cross(vsA[indexA] - vsB[indexB]);
            var bInHA = (vsB[prevIndexB] - vsA[indexA]).cross(vsB[indexB] - vsA[indexA]);

            // aとbが衝突していたらkindフラグを更新
            var intersect = Collision.getSegmentsIntersectionPoint(
                    new Segment2(vsA[prevIndexA], vsA[indexA]),
                    new Segment2(vsB[prevIndexB], vsB[indexB]));

            switch(intersect)
            {
                case Some(point):
                    if(Type.enumEq(kind, Unknown)) advanceA = advanceB = 0;

                    resultVertices.push(point);
                    kind = if(bInHA > 0) Ain else if(aInHB > 0) Bin else kind;
                case None:
            }

            // aとbが同一直線上
            if(cross == 0 && bInHA == 0 && aInHB == 0)
            {
                switch(kind)
                {
                    case Ain:
                        indexB = (indexB + 1) % sizeB;
                        advanceB++;
                    case Bin | Unknown:
                        indexA = (indexA + 1) % sizeA;
                        advanceA++;
                }
            }
            if(cross >= 0)
            {
                if(aInHB > 0)
                {
                    if(Type.enumEq(kind, Ain))
                    {
                        resultVertices.push(vsA[indexA]);
                        indexA = (indexA + 1) % sizeA;
                        advanceA++;
                    }
                }
                else
                {
                    if(Type.enumEq(kind, Bin))
                    {
                        resultVertices.push(vsB[indexB]);
                        indexB = (indexB + 1) % sizeB;
                        advanceB++;
                    }
                }
            }
            else
            {
                if(bInHA > 0)
                {
                    if(Type.enumEq(kind, Bin))
                    {
                        resultVertices.push(vsB[indexB]);
                        indexB = (indexB + 1) % sizeB;
                        advanceB++;
                    }
                }
                else
                {
                    if(Type.enumEq(kind, Ain))
                    {
                        resultVertices.push(vsA[indexA]);
                        indexA = (indexA + 1) % sizeA;
                        advanceA++;
                    }
                }
            }
        }
        while((advanceA < sizeA || advanceB < sizeB) && advanceA < sizeA * 2 && advanceB < sizeB * 2);

        if(Type.enumEq(kind, Unknown))
        {
            if(Collision.convexContains(convB, vsA[0]))return Some(convA);
            if(Collision.convexContains(convA, vsB[0]))return Some(convB);
        }

        return if(resultVertices.length >= 3) Some(new ConvexHull2(resultVertices)) else None;
    }
}

private enum Kind
{
    Ain;
    Bin;
    Unknown;
}
