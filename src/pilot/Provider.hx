package pilot;

final class Provider<T> extends Component {

  @:attribute var id:String;
  @:attribute var value:T;
  @:attribute var children:Children;

  var _pilot_subContext:Context;

  override function render() return html(<>{children}</>);

  function _pilot_setSubContext(context:Context) {
    _pilot_subContext = context.copy();
    _pilot_subContext.set(id, value);
  }

  override function _pilot_update(attrs:Dynamic, context:Context) {
    _pilot_context = context;
    if (_pilot_wire == null && _pilot_shouldRender(attrs)) {
      _pilot_setProperties(attrs, context);
      _pilot_doInits();
      _pilot_setSubContext(context);
      _pilot_doInitialRender(render(), _pilot_subContext);
    } else if (_pilot_shouldRender(attrs)) {
      _pilot_setProperties(attrs, context);
      _pilot_setSubContext(context);
      _pilot_doDiffRender(render(), _pilot_subContext);
    }
  }

}
