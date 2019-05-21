package nengine.physics.dynamics.contacts;
import nengine.math.*;
import nengine.physics.collision.shapes.CircleShape;
import nengine.util.Settings;
using nengine.physics.collision.ManifoldFunction;

class ContactSolver
{
    private var step:TimeStep;
    private var contacts = new Array<Contact>();
    private var velocityConstraints = new Array<ContactVelocityConstraint>();
    private var positionConstraints = new Array<ContactPositionConstraint>();
    private var positions:Array<Position>;
    private var velocities:Array<Velocity>;
    public var blockSolve = true;
    public function new(step:TimeStep, contactList:Contact, positions:Array<Position>, velocities:Array<Velocity>)
    {
        this.step = step;
        this.positions = positions;
        this.velocities = velocities;
        var contact = contactList;
        var index = 0;
        while(contact != null)
        {
            contacts.push(contact);
            var shapeA = contact.shapeA;
            var shapeB = contact.shapeB;
            var bodyA = shapeA.body;
            var bodyB = shapeB.body;
            var manifold = contact.manifold;
            Settings.assert(manifold != None);

            var vc = new ContactVelocityConstraint();
            velocityConstraints.push(vc);

            vc.friction = contact.friction;
            vc.restitution = contact.restitution;
            vc.tangentSpeed = contact.tangentSpeed;
            vc.indexA = bodyA.index;
            vc.indexB = bodyB.index;
            vc.invMassA = bodyA.invMass;
            vc.invMassB = bodyB.invMass;
            vc.invInertiaA = bodyA.invInertia;
            vc.invInertiaB = bodyB.invInertia;
            vc.contactIndex = index;
            vc.k.setZero();
            vc.normalMass.setZero();

            var pc = new ContactPositionConstraint();
            positionConstraints.push(pc);

            pc.indexA = bodyA.index;
            pc.indexB = bodyB.index;
            pc.invMassA = bodyA.invMass;
            pc.invMassB = bodyB.invMass;
            pc.localCenterA = bodyA.localCenter;
            pc.localCenterB = bodyB.localCenter;
            pc.invInertiaA = bodyA.invInertia;
            pc.invInertiaB = bodyB.invInertia;
            pc.manifold = manifold;

            pc.radiusA = if(shapeA.type == Circle) cast(shapeA, CircleShape).radius else 0;
            pc.radiusB = if(shapeB.type == Circle) cast(shapeB, CircleShape).radius else 0;

            manifold.mapPoints((point)->{
                var vcp = new VelocityConstraintPoint();
                vc.points.push(vcp);
                if(step.warmStarting)
                {
                    vcp.normalImpulse = step.dtRatio * point.normalImpulse;
                    vcp.tangentImpulse = step.dtRatio * point.tangentImpulse;
                }
                else
                {
                    vcp.normalImpulse = 0.0;
                    vcp.tangentImpulse = 0.0;
                }
                vcp.rA.setZero();
                vcp.rB.setZero();
                vcp.normalMass = 0.0;
                vcp.tangentMass = 0.0;
                vcp.velocityBias = 0.0;

                pc.localPoints.push(point.localPoint);
            });
            index++;
        }
    }

    public function initializeVelocityConstraints():Void
    {
        for(index in 0...contacts.length)
        {
            var vc = velocityConstraints[index];
            var pc = positionConstraints[index];

            var radiusA = pc.radiusA;
            var radiusB = pc.radiusB;
            var manifold = contacts[vc.contactIndex].manifold;

            var indexA = vc.indexA;
            var indexB = vc.indexB;

            var mA = vc.invMassA;
            var mB = vc.invMassB;
            var iA = vc.invInertiaA;
            var iB = vc.invInertiaB;
            var localCenterA = pc.localCenterA;
            var localCenterB = pc.localCenterB;

            var cA = positions[indexA].c;
            var aA = positions[indexA].a;
            var vA = velocities[indexA].v;
            var wA = velocities[indexA].w;

            var cB = positions[indexB].c;
            var aB = positions[indexB].a;
            var vB = velocities[indexB].v;
            var wB = velocities[indexB].w;

            Settings.assert(manifold != None);

            var transformA = new Transform2();
            var transformB = new Transform2();
            transformA.rotation.set(aA);
            transformB.rotation.set(aB);
            transformA.position = cA - transformA.rotation * localCenterA;
            transformB.position = cB - transformB.rotation * localCenterB;

            var worldManifold = new WorldManifold(manifold, transformA, radiusA, transformB, radiusB);

            vc.normal = worldManifold.normal;
            
            for(index2 in 0...vc.points.length)
            {
                var vcp = vc.points[index2];
                vcp.rA = worldManifold.points[index2] - cA;
                vcp.rB = worldManifold.points[index2] - cB;

                var rnA = vcp.rA.cross(vc.normal);
                var rnB = vcp.rB.cross(vc.normal);

                var kNormal = mA + mB + iA * rnA * rnA + iB * rnB * rnB;

                vcp.normalMass = if(kNormal > 0.0) 1.0/kNormal else 0.0;

                var tangent = Vec2.crossVF(vc.normal, 1.0);

                var rtA = vcp.rA.cross(tangent);
                var rtB = vcp.rB.cross(tangent);

                var kTangent = mA + mB + iA * rtA * rtA + iB * rtB * rtB;

                vcp.tangentMass = if(kTangent > 0.0) 1.0/kTangent else 0.0;

                // setup a velocity bias for restitution
                vcp.velocityBias = 0.0;
                var vRel = vc.normal.dot(vB + Vec2.crossFV(wB, vcp.rB) - vA - Vec2.crossFV(wA, vcp.rA));
                if(vRel < -Settings.velocityThrehold)
                {
                    vcp.velocityBias = -vc.restitution * vRel;
                }
            }

            if(vc.points.length == 2 && blockSolve)
            {
                var vcp1 = vc.points[0];
                var vcp2 = vc.points[1];

                var rn1A = vcp1.rA.cross(vc.normal);
                var rn1B = vcp1.rB.cross(vc.normal);
                var rn2A = vcp2.rA.cross(vc.normal);
                var rn2B = vcp2.rB.cross(vc.normal);

                var k11 = mA + mB + iA * rn1A * rn1A + iB * rn1B * rn1B;
                var k22 = mA + mB + iA * rn2A * rn2A + iB * rn2B * rn2B;
                var k12 = mA + mB + iA * rn1A * rn2A + iB * rn1B * rn2B;

                //  ensure a reasonable condition number
                final maxConditionNumber = 1000.0;
                if(k11 * k11 < maxConditionNumber * (k11 * k22 - k12 * k12))
                {
                    // k is safe to invert
                    vc.k.c1.set(k11, k12);
                    vc.k.c2.set(k12, k22);
                    vc.normalMass = vc.k.getInverse();
                }
                else
                {
                    vc.points.pop();
                }
            }
        }
    }

    public function warmStart():Void
    {
        for(vc in velocityConstraints)
        {
            var indexA = vc.indexA;
            var indexB = vc.indexB;
            var mA = vc.invMassA;
            var iA = vc.invInertiaA;
            var mB = vc.invMassB;
            var iB = vc.invInertiaB;

            var vA = velocities[indexA].v;
            var wA = velocities[indexA].w;
            var vB = velocities[indexB].v;
            var wB = velocities[indexB].w;

            var normal = vc.normal;
            var tangent = Vec2.crossVF(normal, 1.0);

            for(vcp in vc.points)
            {
                var p = vcp.normalImpulse * normal + vcp.tangentImpulse * tangent;
                wA -= iA * vcp.rA.cross(p);
                vA -= mA * p;
                wB += iB * vcp.rB.cross(p);
                vB += mB * p;
            }

            velocities[indexA].v = vA;
            velocities[indexA].w = wA;
            velocities[indexB].v = vB;
            velocities[indexB].w = wB;
        }
    }

    public function solveVelocityConstraints():Void
    {
        for(vc in velocityConstraints)
        {
            var indexA = vc.indexA;
            var indexB = vc.indexB;
            var mA = vc.invMassA;
            var iA = vc.invInertiaA;
            var mB = vc.invMassB;
            var iB = vc.invInertiaB;

            var vA = velocities[indexA].v;
            var wA = velocities[indexA].w;
            var vB = velocities[indexB].v;
            var wB = velocities[indexB].w;

            var normal = vc.normal;
            var tangent = Vec2.crossVF(normal, 1.0);
            var friction = vc.friction;

            Settings.assert(vc.points.length == 1 || vc.points.length == 2);

            for(vcp in vc.points)
            {
                // relative velocity at contact
                var dv = vB + Vec2.crossFV(wB, vcp.rB) - vA - Vec2.crossFV(wB, vcp.rA);

                // compute tangent force
                var vt = dv.dot(tangent) - vc.tangentSpeed;
                var lambda = vcp.tangentMass * (-vt);

                // clamp the accumulated force
                var maxFriction = friction * vcp.normalImpulse;
                var newImpulse = Math2.clamp(vcp.tangentImpulse + lambda, -maxFriction, maxFriction);
                lambda = newImpulse - vcp.tangentImpulse;
                vcp.tangentImpulse = newImpulse;

                // apply contact impulse
                var p = lambda * tangent;

                vA -= mA * p;
                wA -= iA * vcp.rA.cross(p);

                vB += mB * p;
                wB += iB * vcp.rB.cross(p);
            }

            // solve normal constraints
            if(vc.points.length == 1 || !blockSolve)
            {
                for(vcp in vc.points)
                {
                    // relaive velocity at contact
                    var dv = vB + Vec2.crossFV(wB, vcp.rB) - vA - Vec2.crossFV(wA, vcp.rA);

                    // compute normal impulse
                    var vn = dv.dot(normal);
                    var lambda = -vcp.normalMass * (vn - vcp.velocityBias);

                    // clamp the accumulated impulse
                    var newImpulse = Math.max(vcp.normalImpulse + lambda, 0.0);
                    lambda = newImpulse - vcp.normalImpulse;
                    vcp.normalImpulse = newImpulse;

                    // apply contact impulse
                    var p = lambda * normal;
                    vA -= mA * p;
                    wA -= iA * vcp.rA.cross(p);

                    vB += mB * p;
                    wB += iB * vcp.rB.cross(p);
                }
            }
            else
            {
                var cp1 = vc.points[0];
                var cp2 = vc.points[1];

                var a = new Vec2(cp1.normalImpulse, cp2.normalImpulse);
                Settings.assert(a.x >= 0.0 && a.y >= 0.0);

                // relative velocity at contact
                var dv1 = vB + Vec2.crossFV(wB, cp1.rB) - vA - Vec2.crossFV(wA, cp1.rA);
                var dv2 = vB + Vec2.crossFV(wB, cp2.rB) - vA - Vec2.crossFV(wA, cp2.rA);
                
                // compute normal velocity
                var vn1 = dv1.dot(normal);
                var vn2 = dv2.dot(normal);

                var b = new Vec2(vn1 - cp1.velocityBias, vn2 - cp1.velocityBias);

                // compute b
                b -= vc.k * a;
#if debugSolver
                final errorTol = 1e-3;
#end
                // TODO:ここwhile使ってるのgotoしないためだけなので何かしらきれいにする方法はないものか
                while(true)
                {
                    var x = -(vc.normalMass * b);

                    if(x.x >= 0.0 && x.y >= 0.0)
                    {
                        // case 1
                        // get the incremental impulse
                        var d = x - a;

                        // apply incremental impulse
                        var p1 = d.x * normal;
                        var p2 = d.y * normal;
                        vA -= mA * (p1 + p2);
                        wA -= iA * (cp1.rA.cross(p1) + cp2.rA.cross(p2));

                        vB += mB * (p1 + p2);
                        wB += iB * (cp1.rB.cross(p1) + cp2.rB.cross(p2));

                        // accumulate
                        cp1.normalImpulse = x.x;
                        cp2.normalImpulse = x.y;

#if debugSolver
                        // postconditions
                        dv1 = vB + Vec2.crossFV(wB, cp1.rB) - vA - Vec2.crossFV(wA, cp1.rA);
                        dv2 = vB + Vec2.crossFV(wB, cp2.rB) - vA - Vec2.crossFV(wA, cp2.rA);

                        // compute normal velocity
                        vn1 = dv1.dot(normal);
                        vn2 = dv2.dot(normal);

                        Settings.assert(Math.abs(vn1 - cp1.velocityBias) < errorTol);
                        Settings.assert(Math.abs(vn2 - cp2.velocityBias) < errorTol);
#end
                        break;
                    }

                    // case 2
                    x.x = -(cp1.normalMass * b.x);
                    x.y = 0.0;
                    vn1 = 0.0;
                    vn2 = vc.k.c1.y * x.x + b.y;
                    if(x.x >= 0 && vn2 >= 0.0)
                    {
                        // get the incremental impulse
                        var d = x - a;

                        // apply incremental impulse
                        var p1 = d.x * normal;
                        var p2 = d.y * normal;
                        vA -= mA * (p1 + p2);
                        wA -= iA * (cp1.rA.cross(p1) + cp2.rA.cross(p2));

                        vB += mB * (p1 + p2);
                        wB += iB * (cp1.rB.cross(p1) + cp2.rB.cross(p2));

                        // accumulate
                        cp1.normalImpulse = x.x;
                        cp2.normalImpulse = x.y;

#if debugSolver
                        // postconditions
                        dv1 = vB + Vec2.crossFV(wB, cp1.rB) - vA - Vec2.crossFV(wA, cp1.rA);

                        // compute normal velocity
                        vn1 = dv1.dot(normal);

                        Settings.assert(Math.abs(vn1 - cp1.velocityBias) < errorTol);
#end
                        break;
                    }

                    // case 3
                    x.x = 0.0;
                    x.y = -cp2.normalMass * b.y;
                    vn1 = vc.k.c2.x * x.y + b.x;
                    vn2 = 0.0;
                    if(x.y >= 0.0 && vn1 >= 0.0)
                    {
                        // resubstitute for the incremental impulse
                        var d = x - a;

                        // apply incremental impulse
                        var p1 = d.x * normal;
                        var p2 = d.y * normal;
                        vA -= mA * (p1 + p2);
                        wA -= iA * (cp1.rA.cross(p1) + cp2.rA.cross(p2));

                        vB += mB * (p1 + p2);
                        wB += iB * (cp1.rB.cross(p1) + cp2.rB.cross(p2));

                        // accumulate
                        cp1.normalImpulse = x.x;
                        cp2.normalImpulse = x.y;
#if debugSolver
                        // postconditions
                        dv2 = vB + Vec2.crossFV(wB, cp2.rB) - vA - Vec2.crossFV(wA, cp2.rA);

                        // compute normal velocity
                        vn2 = dv2.dot(normal);

                        Settings.assert(Math.abs(vn2 - cp2.velocityBias) < errorTol);
#end
                        break;
                    }

                    // case 4
                    x.x = 0.0;
                    x.y = 0.0;
                    vn1 = b.x;
                    vn2 = b.y;

                    if(vn1 >= 0.0 && vn2 >= 0.0)
                    {
                        // resubstitute for the incremental impulse
                        var d = x - a;

                         // apply incremental impulse
                        var p1 = d.x * normal;
                        var p2 = d.y * normal;
                        vA -= mA * (p1 + p2);
                        wA -= iA * (cp1.rA.cross(p1) + cp2.rA.cross(p2));

                        vB += mB * (p1 + p2);
                        wB += iB * (cp1.rB.cross(p1) + cp2.rB.cross(p2));

                        // accumulate
                        cp1.normalImpulse = x.x;
                        cp2.normalImpulse = x.y;

                        break;
                    }

                    // no solution
                    break;
                }
            }
            velocities[indexA].v = vA;
            velocities[indexA].w = wA;
            velocities[indexB].v = vB;
            velocities[indexB].w = wB;
        }
    }

    public function storeImpulses():Void
    {
        for(vc in velocityConstraints)
        {
            var manifoldPoints = contacts[vc.contactIndex].manifold.points();

            for(index in 0...vc.points.length)
            {
                manifoldPoints[index].normalImpulse = vc.points[index].normalImpulse;
                manifoldPoints[index].tangentImpulse = vc.points[index].tangentImpulse;
            }
        }
    }

    public function solvePositionConstraints():Bool
    {
        var minSeparation = 0.0;

        for(index in 0...positionConstraints.length)
        {
            var pc = positionConstraints[index];

            var indexA = pc.indexA;
            var indexB = pc.indexB;
            var localCenterA = pc.localCenterA;
            var mA = pc.invMassA;
            var iA = pc.invInertiaA;
            var localCenterB = pc.localCenterB;
            var mB = pc.invMassB;
            var iB = pc.invInertiaB;
            
            var cA = positions[indexA].c;
            var aA = positions[indexA].a;

            var cB = positions[indexB].c;
            var aB = positions[indexB].a;

            // solve normal constraints
            for(index2 in 0...pc.localPoints.length)
            {
                var transformA = new Transform2();
                var transformB = new Transform2();
                transformA.rotation.set(aA);
                transformB.rotation.set(aB);
                transformA.position = cA - transformA.rotation * localCenterA;
                transformB.position = cB - transformB.rotation * localCenterB;

                var psm = new PositionSolverManifold(pc, transformA, transformB, index2);
                var normal = psm.normal;

                var point = psm.point;
                var separatiton = psm.separation;

                var rA = point - cA;
                var rB = point - cB;

                // track max constraint error
                minSeparation = Math.min(minSeparation, separatiton);

                // prevent large corrections and allow slop
                var c = Math2.clamp(Settings.baumgarte * (separatiton + Settings.linearSlop), Settings.maxLinearCorrection, 0.0);

                // compute the effective mass
                var rnA = rA.cross(normal);
                var rnB = rB.cross(normal);
                var k = mA + mB + iA * rnA * rnA + iB * rnB * rnB;

                // compute normal impulse
                var impulse = if(k > 0.0) -c/k else 0.0;

                var p = impulse * normal;

                cA -= mA * p;
                aA -= iA * rA.cross(p);

                cB += mB * p;
                aB += iB * rB.cross(p);
            }
            positions[indexA].c = cA;
            positions[indexA].a = aA;

            positions[indexB].c = cB;
            positions[indexB].a = aB;
        }
        // we can't expect minSeparation >= -linearSlop because we don't
        // push the separation above -linearSlop
        return minSeparation >= -3.0 * Settings.linearSlop;
    }
}
