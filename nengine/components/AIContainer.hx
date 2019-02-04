package nengine.components;

import ecs.Component;
import nengine.components.ai.*;

class AIContainer implements Component
{
    public var name(default, null) = "AIContainer";

    public var aiNodes:List<AINode>;

    public function new(aiNodes:Array<AINode>)
    {
        this.aiNodes = Lambda.list(aiNodes);
    }
}
