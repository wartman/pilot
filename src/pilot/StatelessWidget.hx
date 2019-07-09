package pilot;

@:autoBuild(pilot.macro.WidgetBuilder.build({ stateful: false }))
class StatelessWidget implements Widget {

  function build():VNode {
    return null;
  }
  
  public function render():VNode {
    var vnode = build();
    #if js
      vnode.hooks.attach = attached;
      vnode.hooks.detach = detached;
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
