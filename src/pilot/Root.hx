package pilot;

class Root {
  
  var target:NodeWire<Dynamic>;
  public final context:Context;

  public function new(node:Node) {
    context = new Context();
    target = new NodeWire(node, {}, context);
    target.hydrate(context);
  }

  public function update(vNode:VNode) {
    target._pilot_update({}, [ vNode ], context);
  }

}
