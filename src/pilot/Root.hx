package pilot;

class Root {
  
  public inline static function forId(id:String) {
    return new Root(Dom.getElementById(id));
  }

  public inline static function forBody() {
    return new Root(Dom.getBody());
  }

  var target:NodeWire<Dynamic>;
  final context:Context;

  public function new(node:Node, ?initialContext:Map<String, Dynamic>) {
    context = new Context(initialContext);
    target = new NodeWire(node, {}, context);
    target.hydrate(context);
  }

  public function update(vNode:VNode) {
    target._pilot_update({}, [ vNode ], context);
  }

  public inline function getContext() {
    return context;
  }

  public inline function getNode() {
    return target._pilot_getReal();
  }

  public inline function toString() {
    return getNode().toString();
  }

}
