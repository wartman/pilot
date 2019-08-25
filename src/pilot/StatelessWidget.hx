package pilot;

@:autoBuild(pilot.macro.WidgetBuilder.build({ 
  stateful: false, 
  styled: true
}))
class StatelessWidget implements Widget {

  function build():VNode {
    return null;
  }
  
  public function render():VNode {
    var vnode = build();
    #if js

      var attachHook = vnode.hooks.attach;
      vnode.hooks.attach = attachHook == null 
        ? attached
        : vnode -> {
          attachHook(vnode);
          attached(vnode);
        };
        
      var detachHook = vnode.hooks.detach;
      vnode.hooks.detach = detachHook == null 
        ? detached
        : () -> {
          detachHook();
          detached();
        };

    #end
    return vnode;
  }

  #if js
    
    public function attached(vnode:VNode) {
      // noop
    }

    public function detached() {
      // noop
    }

  #end

}
