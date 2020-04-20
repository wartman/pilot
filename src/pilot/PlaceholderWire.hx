package pilot;

class PlaceholderWire<Node> implements Wire<Node, {}> {
  
  final node:Node;

  public function new(node:Node) {
    this.node = node;
  }

  public function __getNodes():Array<Node> {
    return [ node ];
  }
  
  public function __hydrate(
    cursor:Cursor<Node>,
    attrs:{},
    ?children:Array<VNode>,
    parent:Component,
    context:Context<Node>,
    effectQueue:Array<()->Void>
  ):Void {
    // noop
  }

  public function __update(
    attrs:{},
    ?children:Array<VNode>, 
    context:Context<Node>, 
    parent:Component,
		effectQueue:Array<()->Void>
  ):Void {
    // noop
  }

  public function __destroy():Void {
    // noop
  }

}
