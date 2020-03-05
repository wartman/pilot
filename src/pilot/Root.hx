package pilot;

import pilot.dom.*;

class Root {
  
  public inline static function forId(id:String) {
    return new Root(Document.root.getElementById(id));
  }

  var target:NodeWire<Dynamic>;
  final context:Context;

  public function new(el:Element, ?initialContext:Map<String, Dynamic>) {
    context = new Context(initialContext);
    target = new NodeWire(el, {}, context);
    target.hydrate(context);
  }

  public function update(vNode:VNode) {
    var later = new Signal();
    target.__update({}, [ vNode ], later);
    later.enqueue(null);
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
