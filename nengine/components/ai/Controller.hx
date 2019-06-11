package nengine.components.ai;
import ecs.Entity;
import ecs.World;
import nengine.math.Vec2;

// WorldやEntityの状態からOperatorへ対する入力を決める
// EntityやWorldに書き込んではいけない
interface Controller<Button, Stick>
{
    public var world:World;
    public var entity:Entity;
    public function isActive():Bool;
    public function update():Void;
    public function getInput(input:Button):Bool;
    public function getDirection(input:Stick):Vec2;
}
