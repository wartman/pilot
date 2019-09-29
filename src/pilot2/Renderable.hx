package pilot2;

@:allow(pilot2.Differ)
interface Renderable {
  private function _pilot_getId():String;
  private function _pilot_getVNode():VNode;
  public function render(context:Context):VNode;
  public function dispose():Void;
}
