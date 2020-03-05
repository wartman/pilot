package pilot;

interface Plugin {
  public function __connect(component:Component):Void;
  public function __disconnect(component:Component):Void;
}
