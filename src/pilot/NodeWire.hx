package pilot;

class NodeWire<Node, Attrs:{}> implements Wire<Node, Attrs> {
  
  final node:Node;
  var lastAttrs:Attrs;
  var cache:WireCache<Node>;
  var context:Context<Node>;

  public function new(node, context) {
    this.node = node;
    this.context = context;
  }

  public function __getNodes():Array<Node> {
    return [ node ];
  }

  public function __hydrate(
    cursor:Cursor<Node>,
    attrs:Attrs,
    ?children:Array<VNode>,
    parent:Component,
    context:Context<Node>,
    effectQueue:Array<()->Void>
  ):Void {
    this.context = context;
    this.context.engine.differ.diffObject(
      {},
      attrs,
      (key, oldValue, newValue) -> {
        // Only wire up events
        if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
          context.engine.updateNodeAttr(node, key, oldValue, newValue);
        }
      }
    );
    this.cache = this.context.engine.differ.hydrate(
      cursor,
      children,
      parent,
      this.context,
      effectQueue
    );
  }

  public function __update(
    attrs:Attrs,
    ?children:Array<VNode>, 
    context:Context<Node>, 
    parent:Component,
		effectQueue:Array<()->Void>
  ):Void {
    var before = cache;
    var previousCount = 0;

    context.engine.differ.diffObject(
      lastAttrs,
      attrs,
      context.engine.updateNodeAttr.bind(node)
    );
    lastAttrs = attrs;

    cache = context.engine.differ.diff(
      children,
      parent,
      context,
      effectQueue,
      Helpers.createPreviousResolver(before)
    );

    if (before != null) {
      for (wire in before.children) {
        previousCount += wire.__getNodes().length;
      }
      for (t in before.types) t.each(wire -> wire.__destroy());
    }

    context.engine.differ.setChildren(
      previousCount,
      context.engine.traverseChildren(node),
      cache
    );
  }

  public function __destroy():Void {
    if (cache != null) for (c in cache.children) {
      c.__destroy();
    }
  }

}
