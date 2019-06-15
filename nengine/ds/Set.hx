package nengine.math;

interface Set<T>
{
    public function add(element:T, compare:T -> T -> Int):Set<T>;
    public function remove(element:T, compare:T -> T -> Int):Set<T>;
    public function has(element:T, compare:T -> T -> Int):Bool;
}
