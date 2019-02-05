package nengine.components;
import ecs.Component;
import nengine.math.Vec2;

interface Controller extends Component
{
    public function getInput(input:ControllerInput):Bool;
    public function getDirection(input:ControllerStickInput):Vec2;
}
