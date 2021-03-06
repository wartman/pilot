package pilot;

// @todo: Decide if there is a better way of handling this
//        that does not involve wrapping a child component.
@:access(pilot.Component)
@:autoBuild(pilot.builder.StateBuilder.build())
class State implements Wire<Dynamic, Dynamic> {

  var __component:Component;
  var __context:Context<Dynamic>;

  public function __getNodes() {
    return __component.__getNodes();
  }

  public function __update(
    attrs:Dynamic,
    ?_:Array<VNode>,
    context:Context<Dynamic>,
    parent:Component,
    effectQueue:Array<()->Void>
  ) {
    __component.__update(attrs, _, __setContext(context), parent, effectQueue);
  }

  public function __hydrate(
    cursor:Cursor<Dynamic>,
    attrs:Dynamic,
    ?_:Array<VNode>,
    parent:Component,
    context:Context<Dynamic>,
    effectQueue:Array<()->Void>
  ) {
    __component.__hydrate(cursor, attrs, _, parent, __setContext(context), effectQueue);
  }

  public function __destroy() {
    __component.__destroy();
    __component = null;
    __context = null;
  }

  function __setContext(context:Context<Dynamic>):Context<Dynamic> {
    __context = context.getChild();
    __register();
    return __context;
  }

  function __register() {
    // handled by macro
  }

}

final class StateComponent extends Component {

  @:attribute var children:Children;

  override function render():VNode return VFragment(children);

}
