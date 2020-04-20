package pilot;

@:access(pilot.NodeWire)
abstract Root<Node>(NodeWire<Node, Dynamic>) {

  public inline function new(node:Node, context:Context<Node>) {
    this = new NodeWire(node, context);
  }

  /**
    Clears any existing children of the target node and replaces it 
    with the given vNode. 
  **/
  public function replace(vNode:VNode) {
    var cursor = this.context.engine.traverseChildren(this.node);
    while (cursor.current() != null) if (!cursor.delete()) break;
    update(vNode);
  }

  /**
    Hydrate the target node. Use this if you're hydrating the result of a
    server-side render. Note that this method expects things to match up
    *exactly*. If they don't, odd things will happen (and probably break).
  **/
  public function hydrate(vNode:VNode) {
    this.__hydrate(
      this.context.engine.traverseChildren(this.node),
      {},
      [ vNode ],
      null,
      this.context
    );
  }

  /**
    Updates the contents of the target node. If the target has children
    when this is run for the first time they will NOT be replaced.

    Typically, you should use `replace` or `hydrate` to initialize 
    a `Root`, and then call `update` for any later changes.
  **/
  public function update(vNode:VNode) {
    var effectQueue:Array<()->Void> = [];
    this.__update({}, [ vNode ], this.context, null, effectQueue);
    Helpers.commitComponentEffects(effectQueue);
  }

  public inline function toString() {
    return this.context.engine.nodeToString(this.node);
  }

}
