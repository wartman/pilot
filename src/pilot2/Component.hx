package pilot2;

@:allow(pilot2.Differ)
interface Component {
  private var lastRender:VNode;
  private function setProperties(props:Dynamic):Void;
  private function getProperties():Dynamic;
  public function render():VNode;
}
