package pilot;

import pilot.VNode;

@:forward
abstract Placeholder(VNode) to VNode {
  
  inline public function new() {
    this = new VNode({
      name: '[placeholder]',
      type: VNodePlaceholder
    });
  }

}
