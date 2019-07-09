package pilot;

#if js
  using pilot.Differ;
#end

@:autoBuild(pilot.macro.WidgetBuilder.build({ stateful: true }))
class StatefulWidget implements Widget {

  function build():VNode {
    return null;
  }

  #if js
    
    var _pilot_vnode:VNode;

    public function render():VNode {
      _pilot_vnode = build();
      _pilot_vnode.hooks.attach = _pilot_attached;
      _pilot_vnode.hooks.detach = _pilot_detached;
      return _pilot_vnode;
    }

    public function patch() {
      if (_pilot_vnode == null) return;
      if (_pilot_vnode.node == null) return;
      _pilot_vnode.node.patch(render());
    }

    final function _pilot_attached(vnode:VNode) {
      _pilot_vnode = vnode;
      attached(_pilot_vnode);
    }

    final function _pilot_detached() {
      _pilot_vnode = null;
      detached();
    }

    public function attached(vnode:VNode) {
      // noop
    }

    public function detached() {
      // noop
    }

  #else

    public function render():VNode {
      return build();
    }

    public function patch() {
      // noop for now?
    }

  #end

}
