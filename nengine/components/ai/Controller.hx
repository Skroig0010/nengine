package nengine.components.ai;
import nengine.math.Vec2;

interface AIController extends AINode
{
    public function getInput(input:ControllerInput):Bool;
    public function getDirection(input:ControllerStickInput):Vec2;
}
