package pilot;

@:autoBuild(pilot.macro.WidgetBuilder.build())
class Widget implements Renderable {

  @:noCompletion var _pilot_vNode:VNode;

  function build():VNode {
    return null;
  }
  
  @:noCompletion function _pilot_getId() {
    return 'none';
  }

  @:noCompletion function _pilot_getVNode() {
    return _pilot_vNode;
  }

  @:noCompletion function _pilot_applyHooks(vNode:VNode) {
    // noop
  }
  
  public function render(context:Context):VNode {
    _pilot_vNode = build();
    _pilot_applyHooks(_pilot_vNode);
    return _pilot_vNode;
  }

  public function dispose() {
    _pilot_vNode = null;
  }

}
