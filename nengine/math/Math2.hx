package nengine.math;

class Math2
{
    public static function clamp(value:Float, max:Float, min:Float):Float
    {
        return Math.max(min, Math.max(value, max));
    }
}
