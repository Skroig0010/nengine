package nengine.physics.collision;
import nengine.components.*;
import nengine.physics.collision.shapes.*;
import nengine.math.*;

class Collision
{
    public static var maxManifoldPoints(default, never) = 2;

    public static inline function collideAABBs(aabbA:AABB2, aabbB:AABB2):Bool
    {
        return aabbA.upperBound.x < aabbB.lowerBound.x
            && aabbA.upperBound.y < aabbB.lowerBound.y
            && aabbB.upperBound.x < aabbA.lowerBound.x
            && aabbB.upperBound.y < aabbA.lowerBound.y;
    }

    public static function collideCircles(
            circleA:CircleShape, transformA:Transform2, 
            circleB:CircleShape, transformB:Transform2):Manifold
    {
        var pointA = transformA * circleA.position;
        var pointB = transformB * circleB.position;
        var distSq = Vec2.distanceSq(pointA, pointB);
        var radius = circleA.radius + circleB.radius;

        if(distSq > radius * radius)
        {
            return Manifold.None;
        }

        return Manifold.Circles(
                [new ManifoldPoint(circleB.position.copy(), 0, 0, {a:ContactType.Vertex(0), b:ContactType.Vertex(0)})],
                new Vec2(), circleA.position.copy());
    }

    public static function collidePolygonAndCircle(
            polyA:PolygonShape, transformA:Transform2,
            circleB:CircleShape, transformB:Transform2):Manifold
    {
        // ポリゴンから見た円の中心位置
        var cLocal = Transform2.mulXT(transformA, transformB * circleB.position);

        // 分離軸探索
        var normalIndex = 0;
        var separation = Math.NEGATIVE_INFINITY;
        var radius = polyA.radius + circleB.radius;
        var vertices = polyA.vertices;
        var normals = polyA.normals;

        for(index in 0...polyA.vertices.length)
        {
            var s = normals[index].dot(cLocal - vertices[index]);

            if(s > radius)
            {
                return Manifold.None;
            }
            
            if(s > separation)
            {
                separation = s;
                normalIndex = index;
            }
        }

        var vertIndex1 = normalIndex;
        var vertIndex2 = getNextIndex(vertIndex1, vertices.length);
        var vertex1 = vertices[vertIndex1];
        var vertex2 = vertices[vertIndex2];

        if(separation < Settings.epsilon)
        {
            return Manifold.FaceA(
                    [new ManifoldPoint(circleB.position.copy(), 0, 0, {a:ContactType.Vertex(0), b:ContactType.Vertex(0)})], 
                    normals[normalIndex], 0.5 * (vertex1 + vertex2));
        }

        var u1 = (cLocal - vertex1).dot(vertex2 - vertex1);
        var u2 = (cLocal - vertex2).dot(vertex1 - vertex2);
        if(u1 <= 0.0)
        {
            if(Vec2.distanceSq(cLocal, vertex1) <= radius * radius)
            {
            return Manifold.FaceA(
                    [new ManifoldPoint(circleB.position.copy(), 0, 0, {a:ContactType.Vertex(0), b:ContactType.Vertex(0)})], 
                    (cLocal - vertex1).normalize(), vertex1);
            }
        }
        else if(u2 <= 0.0)
        {
            if(Vec2.distanceSq(cLocal, vertex2) <= radius * radius)
            {
            return Manifold.FaceA(
                    [new ManifoldPoint(circleB.position.copy(), 0, 0, {a:ContactType.Vertex(0), b:ContactType.Vertex(0)})], 
                    (cLocal - vertex2).normalize(), vertex2);
            }
        }
        else
        {
            var faceCenter = 0.5 * (vertex1 + vertex2);
            var s = (cLocal - faceCenter).dot(normals[vertIndex1]);
            if(s <= radius)
            {
            return Manifold.FaceA(
                    [new ManifoldPoint(circleB.position.copy(), 0, 0, {a:ContactType.Vertex(0), b:ContactType.Vertex(0)})], 
                    normals[vertIndex1], faceCenter);
            }
        }
        return Manifold.None;
    }

    public static function collidePolygons(
            polyA:PolygonShape, transformA:Transform2,
            polyB:PolygonShape, transformB:Transform2):Manifold
    {
        var totalRadius = polyA.radius + polyB.radius;
        var temp1 = findMaxSeparation(polyA, transformA, polyB, transformB);
        var edgeA = temp1.bestIndex;
        var separationA = temp1.maxSeparation;
        if(separationA > totalRadius) return Manifold.None;

        temp1 = findMaxSeparation(polyB, transformB, polyA, transformA);
        var edgeB = temp1.bestIndex;
        var separationB = temp1.maxSeparation;
        if(separationB > totalRadius) return Manifold.None;

        var poly1, poly2:PolygonShape;
        var transform1, transform2:Transform2;
        var edge1:Int;
        var flip:Bool;
        var faceA:Bool;
        final tol = 0.1 * Settings.linearSlop;

        if(separationB > separationA + tol)
        {
            poly1 = polyB;
            poly2 = polyA;
            transform1 = transformB;
            transform2 = transformA;
            edge1 = edgeB;
            faceA = false;
            flip = true;
        }
        else
        {
            poly1 = polyA;
            poly2 = polyB;
            transform1 = transformA;
            transform2 = transformB;
            edge1 = edgeA;
            faceA = true;
            flip = false;
        }

        var incidentEdges = findIncidentEdge(poly1, transform1, edge1, poly2, transform2);

        var iv1 = edge1;
        var iv2 = getNextIndex(edge1, poly1.vertices.length);

        var v11 = poly1.vertices[iv1];
        var v12 = poly1.vertices[iv2];
        
        var localTangent = v12 - v11;
        localTangent = localTangent.normalize();

        var localNormal = Vec2.crossVF(localTangent, 1.0);
        var planePoint = 0.5 * (v11 + v12);

        var tangent = transform1.rotation * localTangent;
        var normal = Vec2.crossVF(tangent, 1.0);

        v11 = transform1 * v11;
        v12 = transform1 * v12;

        // face offset
        var frontOffset = normal.dot(v11);
        
        //side offset
        var sideOffset1 = -(tangent.dot(v11)) + totalRadius;
        var sideOffset2 = tangent.dot(v12) + totalRadius;

        var clipPoints = clipSegmentToLine(incidentEdges, -tangent, sideOffset1, iv1);
        if(clipPoints.length < 2) return Manifold.None;

        clipPoints = clipSegmentToLine(clipPoints, tangent, sideOffset2, iv2);
        if(clipPoints.length < 2) return Manifold.None;

        var points = new Array<ManifoldPoint>();
        for(index in 0...maxManifoldPoints)
        {
            var separation = normal.dot(clipPoints[index].vertex) - frontOffset;
            if(separation <= totalRadius){
                var mp = new ManifoldPoint( Transform2.mulXT(transform2, clipPoints[index].vertex),
                        0, 0, clipPoints[index].contactFeature);
                if(flip)
                {
                    var temp = mp.contactFeature.a;
                    mp.contactFeature.a = mp.contactFeature.b;
                    mp.contactFeature.b = temp;
                }
                points.push(mp);
            }
        }
        return if(points.length == 0)
        {
            Manifold.None;
        }
        else if(faceA)
        {
            Manifold.FaceA(points, localNormal, planePoint);
        }
        else
        {
            Manifold.FaceB(points, localNormal, planePoint);
        }
    }

    private static function clipSegmentToLine(vIn:Array<ClipVertex>, normal:Vec2, offset:Float, vertexIndexA:Int):Array<ClipVertex>
    {
        var distance0 = normal.dot(vIn[0].vertex) - offset;
        var distance1 = normal.dot(vIn[1].vertex) - offset;

        var vOut = new Array<ClipVertex>();

        if(distance0 <= 0.0) vOut.push(vIn[0]);
        if(distance1 <= 0.0) vOut.push(vIn[1]);

        if(distance0 * distance1 < 0.0)
        {
            var interp = distance0 / (distance0 - distance1);
            vOut.push({
                vertex:vIn[0].vertex + interp * (vIn[1].vertex - vIn[0].vertex),
                       contactFeature:{
                           a:Vertex(vertexIndexA),
                           b:Face(switch(vIn[0].contactFeature.b)
                                   {
                                       case Vertex(index):index;
                                       case Face(index):index;
                                   })
                       }
            });
        }
        return vOut;
    }

    private static function findMaxSeparation(
            polyA:PolygonShape, transformA:Transform2,
            polyB:PolygonShape, transformB:Transform2):{bestIndex:Int, maxSeparation:Float}
    {
        var normalsA = polyA.normals;
        var verticesA = polyA.vertices;
        var verticesB = polyB.vertices;
        var transform = Transform2.mulT(transformB, transformA);

        var bestIndex:Int = 0;
        var maxSeparation:Float = Math.NEGATIVE_INFINITY;
        for(index in 0...verticesA.length)
        {
            var n = transform.rotation * normalsA[index];
            var v1 = transform * verticesA[index];

            var si:Float = Math.POSITIVE_INFINITY;
            for(vB in verticesB)
            {
                var sij = n.dot(vB - v1);
                if(sij < si)
                {
                    si = sij;
                }
            }

            if (si > maxSeparation)
            {
                maxSeparation = si;
                bestIndex = index;
            }
        }

        return {
            bestIndex:bestIndex,
            maxSeparation:maxSeparation
        };
    }

    private static function findIncidentEdge(polyA:PolygonShape, transformA:Transform2, edgeA:Int,
            polyB:PolygonShape, transformB:Transform2):Array<ClipVertex>
    {
        var normalsA = polyA.normals;
        var verticesB = polyB.vertices;
        var normalsB = polyB.normals;

        // polyBから見たPolyAのedgeAのnormal
        var normalA = Vec2.rotVecT(transformB.rotation, transformA.rotation * normalsA[edgeA]);

        // edgeAと比べて一番反対方向向いてる線分を探索?
        var minDotIndex = 0;
        var minDot = Math.POSITIVE_INFINITY;
        for(index in 0...polyB.normals.length)
        {
            var dot = normalA.dot(normalsB[index]);
            if(dot < minDot)
            {
                minDot = dot;
                minDotIndex = index;
            }
        }

        var index1 = minDotIndex;
        var index2 = getNextIndex(index1, verticesB.length);

        var c1 = {
            vertex:transformB * verticesB[index1],
            contactFeature:
            {
                a:ContactType.Face(edgeA),
                b:ContactType.Vertex(index1),
            }
        }

        var c2 = {
            vertex:transformB * verticesB[index2],
            contactFeature:
            {
                a:ContactType.Face(edgeA),
                b:ContactType.Vertex(index2),
            }
        }

        return [c1, c2];
    }

    private inline static function getNextIndex(index:Int, length:Int):Int
    {
        return if(index + 1 < length) index + 1 else 0;
    }
}
