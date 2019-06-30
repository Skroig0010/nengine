package nengine.util;
import haxe.ds.Option;

class OptionTools
{
    public static inline function getOrElse<T>(o:Option<T>, e:T):T
    {
        return switch(o)
        {
            case Some(v):v;
            case None:e;
        }
    }

    public static inline function map<In, Out>(o:Option<In>, f:In->Out):Option<Out>
    {
        return switch(o)
        {
            case Some(v):Some(f(v));
            case None:None;
        }
    }

    public static inline function iter<T>(o:Option<T>, f:T->Void):Void
    {
        switch(o)
        {
            case Some(v):f(v);
            case None:
        }
    }

    public static inline function isSome<T>(o:Option<T>):Bool
    {
        return switch(o)
        {
            case Some(_): true;
            case None: false;
        }
    }

    public static inline function isNone<T>(o:Option<T>):Bool
    {
        return switch(o)
        {
            case Some(_): false;
            case None: true;
        }
    }
}
