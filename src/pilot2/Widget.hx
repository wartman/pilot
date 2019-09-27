package pilot2;

@:allow(pilot2.WidgetState)
@:autoBuild(pilot2.macro.WidgetBuilder.build())
class Widget implements Renderable {

  function build():VNode {
    return null;
  }
  
  public function render():VNode {
    var vnode = build();
    #if js
      _pilot_applyHooks(vnode);
    #end
    return vnode;
  }

  #if js

    @:noCompletion final function _pilot_applyHooks(vnode:VNode) {
      vnode.hooks.add(HookPrePatch(widgetWillPatch));
      vnode.hooks.add(HookPostPatch(widgetDidPatch));
      vnode.hooks.add(HookUpdate(widgetWillUpdate));
      vnode.hooks.add(HookRemove(widgetWillBeRemoved));
    }
    
    public function widgetWillPatch(oldVNode:VNode, newVNode:VNode) {
      // noop
    }

    public function widgetDidPatch(oldVNode:VNode, newVNode:VNode) {
      // noop
    }

    public function widgetWillUpdate(oldVNode:Null<VNode>, newVNode:VNode) {
      // noop
    }

    public function widgetWillBeRemoved(vnode:VNode) {
      // noop
    }

  #end

}
