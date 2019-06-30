package nengine.util;
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.ExprTools;

class Settings
{
    public static inline var epsilon = 1e-5;
    public static inline var velocityThrehold = 1.0;
    public static inline var maxTranslation = 2.0;
    public static inline var maxTranslationSquared = maxTranslation * maxTranslation;
    public static inline var baumgarte = 0.2;
    public static inline var linearSlop = 0.005;
    public static inline var polygonRadius = linearSlop * 2.0;
    public static inline var maxLinearCorrection = 0.2;
    public static inline var maxRotation = 0.5 * 3.14159265359;
    public static inline var maxRotationSquared = maxRotation * maxRotation;

    public static function assert(b:Bool):Void
    {
        if(!b)
        {
            throw "assertion failed";
        }
    }
}
