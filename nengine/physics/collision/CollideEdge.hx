package nengine.physics.collision;
import nengine.physics.collision.shapes.*;
import nengine.math.*;

class CollideEdge
{
    public static function collideEdgeAndCircle(
            circleA:CircleShape, transformA:Transform2, 
            edgeB:EdgeShape, transformB:Transform2):Manifold
    {
        // Edgeから見た円の中心位置
        var cLocal = Transform2.mulXT(transformA, transformB * circleB.position);

        var vertexA = edgeA.vertex1;
        var vertexB = edgeA.vertex2;
        var e = vertexB - vertexA;

        // 重心座標
        var u = e.dot(vertexB - cLocal);
        var v = e.dot(cLocal - vertexA);

        var radius = edgeA.radius + circleB.radius;

        // Region A
        if(v <= 0.0)
        {
            var p = vertexA;
            var d = cLocal - p;
            var dd = d.dot(d);

            if(dd > radius * radius)
            {
                return;
            }

            // vertexAに繋がっているEdgeはあるか
            switch(edgeA.vertex0)
            {
                case Some(a1):
                    var b1 = a;
                    var e1 = b1 - a1;
                    var u1 = e1.dot(b1 - cLocal);

                    // 円が前のEdgeの領域に入っているか
                    if(u1 > 0.0)
                    {
                        return;
                    }
                case None:
            }

            return Manifold.Circles(
                    [new ManifoldPoint(circleB.position.copy(), 0, 0, {a:ContactType.Vertex(0), b:ContactType.Vertex(0)})],
                    new Vec2(), p);
        }

        // Region B
        if(u <= 0.0)
        {
            var p = vertexB;
            var d = cLocal - p;
            var dd = d.dot(d);

            if(dd > radius * radius)
            {
                return;
            }

            // vertexBに繋がっているEdgeはあるか
            switch(edgeA.vertex3)
            {
                case Some(b2):
                    var a2 = vertexB;
                    var e2 = b2 - a2;
                    var v2 = e2.dot(cLocal - a2);

                    // 円が次のEdgeの領域に入っているか
                    if(v2 >0.0)
                    {
                        return;
                    }
                case None:
            }

            return Manifold.Circles(
                    [new ManifoldPoint(circleB.position.copy(), 0, 0, {a:ContactType.Vertex(1), b:ContactType.Vertex(0)})],
                    new Vec2(), p);
        }

        // Region AB
        var den = e.dot(e);
        Settings.assert(den > 0.0);
        var p = (1.0 / den) * (u * vertexA + v * vertexB);
        var d = cLocal - p;
        var dd = d.dot(d);
        if(dd > radius * radius)
        {
            return;
        }

        var n = new Vec2(-e.y, e.x);
        if(n.dot(cLocal - vertexA) < 0.0)
        {
            n.set(-n.x, -n.y);
        }
        n.normalize();

        return Manifold.FaceA(
                [new ManifoldPoint(circleB.position.copy(), 0, 0, {a:ContactType.FaceA(0), b:ContactType.Vertex(0)})],
                n, vertexA);
    }

    public static collideEdgeAndPolygon(
            edgeA:EdgeShape, transformA:Transform2, 
            polyB:EdgeShape, transformB:Transform2):Manifold
    {
        var collider = new EdgePolygonCollider();
        collider.collide(edgeA, transformA, polyB, transformB);
    }
}
