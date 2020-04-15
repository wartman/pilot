package pilot;

interface Wire<Node, Attrs:{}> {
  public function __getNodes():Array<Node>;
  public function __update(
    attrs:Attrs,
    ?children:Array<VNode>,
    context:Context<Node>,
    parent:Component,
    effectQueue:Array<()->Void>
  ):Void;
  public function __destroy():Void;
}
