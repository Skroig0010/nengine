package nengine.physics.collision;
import nengine.physics.collision.shapes.*;
import nengine.math.*;

class CollideCircle
{
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
        var vertIndex2 = Collision.getNextIndex(vertIndex1, vertices.length);
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
}
