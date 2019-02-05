package nengine.components;
import ecs.Component;
import nengine.math.Vec2;

interface AIController extends Component
{
    public function getInput(input:ControllerInput):Bool;
    public function getDirection(input:ControllerStickInput):Vec2;
}
