package pilot;

import pilot.core.VNode;

class Root {
  
  var target:NativeNode<Dynamic>;

  public function new(node:RealNode) {
    target = new NativeNode(node);
    target.hydrate();
  }

  public function update(vNode:VNode<RealNode>) {
    target._pilot_updateChildren([ vNode ]);
  }

}
