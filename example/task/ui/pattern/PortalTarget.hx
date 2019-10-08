package task.ui.pattern;

import pilot.*;

class PortalTarget implements Renderable {

  var id:String;
  var vNode:VNode;
  var context:Context;

  public function new(props:{
    id:String
  }) {
    id = props.id;
  }

  function _pilot_getId():String {
    return id;
  }
  
  function _pilot_getVNode():VNode {
    return vNode;
  }

  function buildNode(?child:VNode):VNode {
    return new VNode({
      name: 'div',
      props: { id: id },
      children: child != null ? [ child ] : []
    });
  }

  #if js

    public function set(child:VNode) {
      if (vNode != null) {
        context.differ.subPatch(vNode, buildNode(child));
      }
    }

    public function clear() {
      if (vNode != null) {
        context.differ.subPatch(vNode, buildNode());
      }
    }
  
  #end

  public function render(context:Context):VNode {
    this.context = context;
    vNode = buildNode();
    context.data.set(_pilot_getId(), this);
    return vNode;
  }

  public function dispose():Void {
    vNode = null;
    context.data.remove(_pilot_getId());
  }

}