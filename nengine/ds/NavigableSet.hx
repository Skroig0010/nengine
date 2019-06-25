package nengine.ds;

interface NavigableSet<T> extends SortedSet<T>
{
    public function lower(element:T):Option<T>;
    public function higher(element:T):Option<T>;
}
