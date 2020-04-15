package pilot;

@:access(pilot.NodeWire)
abstract Root<Node>(NodeWire<Node, Dynamic>) {

  public inline function new(node:Node, context:Context<Node>) {
    this = new NodeWire(node, context);
  }

  public inline function update(vNode:VNode) {
    var effectQueue:Array<()->Void> = [];
    this.__update({}, [ vNode ], this.context, null, effectQueue);
    Helpers.commitComponentEffects(effectQueue);
  }

  public inline function toString() {
    return this.context.engine.nodeToString(@:privateAccess this.node);
  }

  public function hydrate(vNode:VNode) {
    // todo
  }

}
