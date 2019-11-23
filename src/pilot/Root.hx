package pilot;

class Root {
  
  var target:NodeWire<Dynamic>;
  final context:Context;

  public function new(node:Node) {
    context = new Context();
    target = new NodeWire(node);
    target.hydrate();
  }

  public function update(vNode:VNode) {
    target._pilot_updateChildren([ vNode ], context);
  }

}
