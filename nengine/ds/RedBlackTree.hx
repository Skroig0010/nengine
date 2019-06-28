package nengine.ds;

class RedBlackTree<T> implements NavigableSet<T>
{
    private final root:TreeNode<T>;
    public var compare:T->T->Int = Reflect.compare;

    public function new(?compare:T->T->Int, root:TreeNode<T> = Leaf) 
    {
        this.root = root;
        this.compare = if(compare != null) compare else Reflect.compare;
    }

    public function add(value:T):RedBlackTree<T>
    {
        return new RedBlackTree(compare, makeBlack(ins(root, value)));
    }

    private function ins(node:TreeNode<T>, v1:T):TreeNode<T>
    {
        return switch(node) 
        {
            case Node(c, t1, v2, t2) if(compare(v1, v2) < 0):
                balance(Node(c, ins(t1, v1), v2, t2));
            case Node(c, t1, v2, t2) if(compare(v1, v2) == 0):
                node;
            case Node(c, t1, v2, t2):
                balance(Node(c, t1, v2, ins(t2, v1)));
            case Leaf:
                Node(Red, Leaf, v1, Leaf);
        }
    }

    private function makeBlack(node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case Node(_, t1, v, t2):
                Node(Black, t1, v, t2);
            case Leaf:
                Leaf;
        }
    }

    private function balance(node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case  Node(Black, Node(Red, Node(Red, t1, v1, t2), v2, t3), v3, t4)
                | Node(Black, Node(Red, t1, v1, Node(Red, t2, v2, t3)), v3, t4)
                | Node(Black, t1, v1, Node(Red, Node(Red, t2, v2, t3), v3, t4))
                | Node(Black, t1, v1, Node(Red, t2, v2, Node(Red, t3, v3, t4))):
                    Node(Red, Node(Black, t1, v1, t2), v2, Node(Black, t3, v3, t4));
            case Node(_, _, _, _):
            node;
            default:
            throw {msg:"balance failed", node:node, tree:this};
        }
    }

    public function remove(value:T):RedBlackTree<T>
    {
        return new RedBlackTree(compare, makeBlack(del(root, value)));
    }

    private function del(node:TreeNode<T>, v1:T):TreeNode<T>
    {
        return switch(node)
        {
            case Leaf:
                Leaf;
            case Node(_, t1, v2, t2):
                if(compare(v1, v2) < 0)
                {
                    delL(v1, node);
                }
                else if(compare(v1, v2) > 0)
                {
                    delR(v1, node);
                }
                else
                {
                    fuse(t1, t2);
                }
            default:
                throw {msg:"del failed", node:node, tree:this};
        }
    }

    private function delL(v:T, node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case Node(_, t1 = Node(Black, _, _, _), v1, t2):
                balL(Node(Black, del(t1, v), v1, t2));
            case Node(_, t1, v1, t2):
                Node(Red, del(t1, v), v1, t2);
            default:
                throw {msg:"delL failed", node:node, tree:this};
        }
    }

    private function balL(node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case Node(Black, Node(Red, t1, v1, t2), v2, t3):
                Node(Red, Node(Black, t1, v1, t2), v2, t3);
            case Node(Black, t1, v1, Node(Black, t2, v2, t3)):
                balance(Node(Black, t1, v1, Node(Red, t2, v2, t3)));
            case Node(Black, t1, v1, Node(Red, Node(Black, t2, v2, t3), v3, Node(Black, t4, v4, t5))):
                Node(Red, Node(Black, t1, v1, t2), v2, balance(Node(Black, t3, v3, Node(Red, t4, v4, t5))));
            default:
                throw {msg:"balL failed", node:node, tree:this};
        }
    }

    private function delR(v:T, node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case Node(_, t1, v1, t2=Node(Black, _, _, _)):
                balR(Node(Black, t1, v1, del(t2, v)));
            case Node(_, t1, v1, t2):
                Node(Red, t1, v1, del(t2, v));
            default:
                throw {msg:"delR failed", node:node, tree:this};
        }
    }

    private function balR(node:TreeNode<T>):TreeNode<T>
    {
        return switch(node)
        {
            case Node(Black, t1, v1, Node(Red, t2, v2, t3)):
                Node(Red, t1, v1, Node(Black, t2, v2, t3));
            case Node(Black, Node(Black, t1, v1, t2), v2, t3):
                balance(Node(Black, Node(Red, t1, v1, t2), v2, t3));
            case Node(Black, Node(Red, Node(Black, t1, v1, t2), v2, Node(Black, t3, v3, t4)), v4, t5):
                Node(Red, balance(Node(Black, Node(Red, t1, v1, t2), v2, t3)), v3, Node(Black, t4, v4, t5));
            default:
                throw {msg:"balR failed", node:node, tree:this};
        }
    }

    private function fuse(node1:TreeNode<T>, node2:TreeNode<T>):TreeNode<T>
    {
        return switch([node1, node2])
        {
            case [Leaf, t] | [t, Leaf]:
                t;
            case [Node(Black, _, _, _), Node(Red, t1, v1, t2)]:
                Node(Red, fuse(node1, t1), v1, t2);
            case [Node(Red, t1, v1, t2), Node(Black, _, _, _)]:
                Node(Red, t1, v1, fuse(t2, node2));
            case [Node(Red, t1, v1, t2), Node(Red, t3, v2, t4)]:
                var s = fuse(t2, t3);
                switch(s)
                {
                    case Node(Red, s1, v3, s2):
                        Node(Red, Node(Red, t1, v1, s1), v3, Node(Red, s2, v2, t4));
                    case Node(Black, _, _, _) | Leaf:
                        Node(Red, t1, v1, Node(Red, s, v2, t4));
                    default:
                        throw {msg:"switch1 in fuse failed", node:s, tree:this};
                }
            case [Node(Black, t1, v1, t2), Node(Black, t3, v2, t4)]:
                var s = fuse(t2, t3);
                switch(s)
                {
                    case Node(Red, s1, v3, s2):
                        Node(Red, Node(Black, t1, v1, s1), v3, Node(Black, s2, v2, t4));
                    case Node(Black, _, _, _) | Leaf:
                        balL(Node(Black, t1, v1, Node(Black, s, v2, t4)));
                    default:
                        throw {msg:"switch2 in fuse failed", node:s, tree:this};
                }
        }
    }

    public function has(element:T):Bool
    {
        var node = root;
        while(true)
        {
            switch(node)
            {
                case Node(_, t1, v, t2) if(compare(element, v) < 0):
                    node = t1;
                case Node(_, t1, v, t2) if(compare(element, v) == 0):
                    return true;
                case Node(_, t1, v, t2) :
                    node = t2;
                case Leaf:
                    return false;
            }
        }
        return false;
    }

    private inline function nodeToOption(node:TreeNode<T>):Option<T>
    {
        return switch(node)
        {
            case Node(_, _, v, _):
                Some(v);
            case Leaf:
                None;
        }
    }

    public function first():Option<T>
    {
        var node = root;
        while(true)
        {
            switch(node)
            {
                case Node(_, Leaf, _, _) | Leaf:
                    break;
                case Node(_, t, _, _):
                    node = t;
            }
        }
        return nodeToOption(node);
    }

    public function last():Option<T>
    {
        var node = root;
        while(true)
        {
            switch(node)
            {
                case Node(_, _, _, Leaf) | Leaf:
                    break;
                case Node(_, _, _, t):
                    node = t;
            }
        }
        return nodeToOption(node);
    }

    public function lower(element:T):Option<T>
    {
        if(element == null)return last();

        return nodeToOption(highestLessThan(element, false));
    }

    private function highestLessThan(element:T, equal:Bool):TreeNode<T>
    {

        var last = Leaf;
        var current = root;
        var comparison = 0;
        var parents = new List<TreeNode<T>>();

        while(true)
        {
            last = current;
            switch(current)
            {
                case Node(_, t1, v, t2):
                    parents.push(current);
                    comparison = compare(element, v);
                    if(comparison > 0)
                    {
                        current = t2;
                    }
                    else if(comparison < 0)
                    {
                        current = t1;
                    }
                    else
                    {
                        parents.pop();
                        return if(equal) last else predecessor(last, parents);
                    }
                case Leaf:
                    break;
            }
        }
        parents.pop();
        return if(comparison < 0) predecessor(last, parents) else last;
    }

    private function predecessor(node:TreeNode<T>, parents:List<TreeNode<T>>):TreeNode<T>
    {
        switch(node)
        {
            case Node(_, Leaf, _, _):
                // 何もしない
            case Node(_, t, _, _):
                node = t;
                // 右下最底部を探索
                while(true)
                {
                    switch(node)
                    {
                        case Node(_, _, _, Leaf):
                            return node;
                        case Node(_, _, _, t):
                            node = t;
                        case Leaf:
                            // 到達し得ない
                            throw {msg:"predecessor failed in second switch", node:node, tree:this};
                    }
                }
            case Leaf:
                // 到達し得ない
                throw {msg:"predecessor failed in first switch", node:node, tree:this};
        }

        var parent = parents.pop();
        while(true)
        {
            switch(parent)
            {
                case Node(_, t, _, _) if(t == node):
                    node = parent;
                    parent = parents.pop();
                case Node(_, _, _, _):
                    break;
                case Leaf:
                    // 到達し得ない
                    throw {msg:"predecessor failed in third switch", node:node, tree:this};
                case null:
                    // 親がいないので葉を返す
                    return Leaf;

            }
        }
        return parent;
    }

    public function higher(element:T):Option<T>
    {
        if(element == null)return None;

        return nodeToOption(lowestGreaterThan(element, false));
    }

    private function lowestGreaterThan(element:T, equal:Bool):TreeNode<T>
    {
        var last  = Leaf;
        var current = root;
        var comparison = 0;
        var parents = new List<TreeNode<T>>();

        while(true)
        {
            last = current;
            switch(current)
            {
                case Node(_, t1, v, t2):
                    parents.push(current);
                    comparison = compare(element, v);
                    if(comparison > 0)
                    {
                        current = t2;
                    }
                    else if(comparison < 0)
                    {
                        current = t1;
                    }
                    else 
                    {
                        parents.pop();
                        return if(equal) current else successor(current, parents);
                    }
                case Leaf:
                    break;
            }
        }
        parents.pop();
        return if(comparison > 0) successor(last, parents) else last;
    }

    private function successor(node:TreeNode<T>, parents:List<TreeNode<T>>):TreeNode<T>
    {
        switch(node)
        {
            case Node(_, _, _, Leaf):
                // 何もしない
            case Node(_, _, _, t):
                node = t;
                // 左下最低部を探索
                while(true)
                {
                    switch(node)
                    {
                        case Node(_, Leaf, _, _):
                            return node;
                        case Node(_, t, _, _):
                            node = t;
                        case Leaf:
                            // 到達し得ない
                            throw {msg:"successor failed in second switch", node:node, tree:this};
                    }
                }
            case Leaf:
                // 到達し得ない
                throw {msg:"successor failed in first switch", node:node, tree:this};
        }

        var parent = parents.pop();
        while(true)
        {
            switch(parent)
            {
                case Node(_, _, _, t) if(t == node):
                    node = parent;
                    parent = parents.pop();
                case Node(_, _, _, _):
                    break;
                case Leaf:
                    // 到達し得ない
                    throw {msg:"successor failed in third switch", node:node, tree:this};
                case null:
                    // 親がいないので葉を返す
                    return Leaf;
            }
        }
        return parent;
    }
}

private enum Color
{
    Red;
    Black;
}

private enum TreeNode<T>
{
    Node(color:Color, lst:TreeNode<T>, value:T, rst:TreeNode<T>);
    Leaf;
}
