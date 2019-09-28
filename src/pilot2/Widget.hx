package pilot2;

@:allow(pilot2.WidgetState)
@:autoBuild(pilot2.macro.WidgetBuilder.build())
class Widget implements Renderable {

  function build():VNode {
    return null;
  }
  
  public function render():VNode {
    var vnode = build();
    _pilot_applyHooks(vnode);
    return vnode;
  }

  @:noCompletion function _pilot_applyHooks(vNode:VNode) {
    // noop
  }

}
