package pilot;

import pilot.dom.*;

class Root {
  
  public inline static function forId(id:String) {
    return new Root(Document.root.getElementById(id));
  }

  var target:NodeWire<Dynamic>;
  final context:Context;

  public function new(node:Node, ?initialContext:Map<String, Dynamic>) {
    context = new Context(initialContext);
    target = new NodeWire(node, {}, context);
    target.hydrate(context);
  }

  public function update(vNode:VNode) {
    var later:Array<()->Void> = [];
    target.__update({}, [ vNode ], context, later);
    if (later.length > 0) for (cb in later) cb();
  }

  public inline function getContext() {
    return context;
  }

  public inline function getNode() {
    return target.__getNodes()[0];
  }

  public inline function toString() {
    var el:Element = cast getNode();
    return el.outerHTML;
  }

}
