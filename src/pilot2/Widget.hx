package pilot2;

@:autoBuild(pilot2.macro.WidgetBuilder.build())
class Widget implements WidgetLike {

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
