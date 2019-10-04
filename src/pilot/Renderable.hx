package pilot;

@:allow(pilot.Differ)
interface Renderable {
  @:noCompletion private function _pilot_getId():String;
  @:noCompletion private function _pilot_getVNode():VNode;
  public function render(context:Context):VNode;
  public function dispose():Void;
}
