package nengine.util;
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.ExprTools;

class Settings
{
    public static inline var maxFloat = 1e37;
    public static inline var epsilon = 1e-5;
    public static inline var pi = 3.14159265359;
    public static inline var velocityThrehold = 1.0;
    public static inline var maxTranslation = 2.0;
    public static inline var maxTranslationSquared = maxTranslation * maxTranslation;
    public static inline var baumgarte = 0.2;
    public static inline var linearSlop = 0.005;
    public static inline var maxLinearCorrection = 0.2;
    public static inline var maxRotation = 0.5 * pi;
    public static inline var maxRotationSquared = maxRotation * maxRotation;

    public static macro function assert(b:Expr):Expr
    {
        return macro{
            if(!$b)throw "assertion failed";
        }
    }
}
