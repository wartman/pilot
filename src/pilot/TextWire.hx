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
    _:Cursor<Node>,
    attrs:{ content: String },
    ?_:Array<VNode>,
    parent:Component,
    context:Context<Node>,
    effectQueue:Array<()->Void>
  ):Void {
    previousAttrs = attrs;
    var engine = context.engine;
    var content = engine.getTextNodeContent(node);

    // We won't get text nodes chopped up correctly from the server side,
    // so we need to do that manually here.
    if (attrs.content != content) {
      engine.updateTextNode(node, attrs.content);
      var newContent = content.substr(attrs.content.length);
      var c = engine.traverseSiblings(node);
      c.step();
      c.insert(engine.createTextNode(newContent));
    }
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
