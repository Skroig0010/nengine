package nengine.components.ai;
import ecs.Entity;

// Entityの操作のみを行う
// 意思決定はコントローラが行う
// キーボード操作できる以上の事はしてはならない
interface EntityOperator
{
    public var entity(null, default):Entity;
    public function update(controller:Controller):Void;
}
