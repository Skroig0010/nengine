package nengine.ds;

interface Set<T>
{
    public function add(element:T):Set<T>;
    public function remove(element:T):Set<T>;
    public function has(element:T):Bool;
}
