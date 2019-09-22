package pilot;

import pilot.VNode;

@:forward
abstract Fragment(VNode) to VNode {
  
  inline public function new(props:{ children:Children }) {
    this = new VNode({
      name: '[fragment]',
      children: props.children,
      type: VNodeFragment
    });
  }

}
