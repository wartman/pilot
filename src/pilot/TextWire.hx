package pilot;

class TextWire<Node> implements Wire<Node, { content: String }> {
  
  final node:Node;
  var previousAttrs:{ content:String } = { content: '' };

  public function new(node:Node) {
    this.node = node;
  }

  public function __getNodes():Array<Node> {
    return [ node ];
  }

  
  public function __hydrate(
    cursor:Cursor<Node>,
    attrs:{ content: String },
    ?children:Array<VNode>,
    parent:Component,
    context:Context<Node>
  ):Void {
    // noop
  }

  public function __update(
    attrs:{ content: String },
    ?children:Array<VNode>, 
    context:Context<Node>, 
    parent:Component,
		effectQueue:Array<()->Void>
  ):Void {
    if (attrs.content != previousAttrs.content) {
      context.engine.updateTextNode(node, attrs.content);
    }
    previousAttrs = attrs;
  }

  public function __destroy():Void {
    // noop
  }

}
