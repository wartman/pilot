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

  // todo: need the `hydrate` method.

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
      (type, key) -> {
        if (before == null) return None;
        if (!before.types.exists(type)) return None;
        return switch before.types.get(type) {
          case null: None;
          case t: switch t.pull(key) {
            case null: None;
            case v: Some(v);
          }
        }
      }
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
