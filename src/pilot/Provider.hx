package pilot;

final class Provider<T> extends Component {

  @:attribute var id:String;
  @:attribute var value:Dynamic;
  @:attribute var children:Children;

  override function render() return html(<>{children}</>);

  override function _pilot_update(attrs:Dynamic, children:Array<VNode>, context:Context) {
    var subContext = context.copy();
    subContext.set(id, value);
    super._pilot_update(attrs, children, subContext);
  }

}
