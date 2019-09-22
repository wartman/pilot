package pilot;

import pilot.VNode;

@:forward
abstract Text(VNode) to VNode {
  
  inline public function new(props:{ 
    content:String
  }) {
    this = new VNode({
      name: props.content,
      type: VNodeText,
    });
  }

}
