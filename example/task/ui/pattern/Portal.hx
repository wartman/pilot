package task.ui.pattern;

import pilot.*;

class Portal implements Renderable {

  final id:String;
  final child:VNode;
  var vNode:VNode;

  public function new(props:{
    id:String,
    child:VNode
  }) {
    id = props.id;
    child = props.child;
  }

  function _pilot_getId():String {
    return id + '-portal';
  }

  function _pilot_getVNode():VNode {
    return vNode;
  }

  public function render(context:Context):VNode {
    var target:PortalTarget = context.data.get(id);
    if (target == null) {
      throw 'No target exists with the id ${id}';
    }
    target.set(child);
    vNode = VNode.create({
      type: VNodePlaceholder(_pilot_getId()),
      hooks: [
        HookDestroy(vn -> if (vn == vNode) target.clear()),
        HookPostPatch((oldVn, _) -> if (oldVn == vNode) target.clear())
      ]
    });
    return vNode;
  }

  public function dispose():Void {
    vNode = null;
  }

}