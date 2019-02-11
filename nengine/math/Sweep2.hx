package nengine.math;
import nengine.physics.Settings;

class Sweep2
{
    // local center of mass position
    public var localCenter:Vec2;
    // world angles
    public var a0:Float;
    public var a:Float;
    // center world positions
    public var c0:Vec2;
    public var c:Vec2;
    public var t0:Float;

    public function new()
    {
    }

    public function set(other:Sweep2):Void
    {
        this.localCenter.setV(other.localCenter);
        this.c0.setV(other.c0);
        this.c.setV(other.c);
        this.a0 = other.a0;
        this.a = other.a;
        this.t0 = other.t0;
    }
    public function copy():Sweep2
    {
        var copy = new Sweep2();
        copy.localCenter.setV(this.localCenter);
        copy.c0.setV(this.c0);
        copy.c.setV(this.c);
        copy.a0 = this.a0;
        copy.a = this.a;
        copy.t0 = this.t0;
        return copy;
    }

    public function getTransform(?alpha:Float = 0):Transform2
    {
        var transform = new Transform2(
                new Vec2(
        (1.0 - alpha) * c0.x + alpha * c.x,
        (1.0 - alpha) * c0.y + alpha * c.y),
                new Rot2((1.0 - alpha) * a0 + alpha * a));
        transform.position = transform.position - transform.rotation * localCenter;
        return transform;
    }

    public function advance(?t:Float = 0) {
        if(t0 < 1.0)throw "Sweep2 err";
        var alpha = (t - t0) / (1.0 - t0);
        c0 += alpha * (c - c0);
        a0 += alpha * (a - a0);
        t0 = t;
    }
}
