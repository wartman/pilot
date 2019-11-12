package pilot;

import pilot.core.Context;
import pilot.core.VNode;

class Root {
  
  var target:NativeNode<Dynamic>;
  final context:Context;

  // Todo: allow setting of context here
  public function new(node:RealNode) {
    context = new Context();
    target = new NativeNode(node);
    target.hydrate();
  }

  public function update(vNode:VNode<RealNode>) {
    target._pilot_updateChildren([ vNode ], context);
  }

}
