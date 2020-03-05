package pilot;

final class Provider<T> extends Component {

  @:attribute var id:String;
  @:attribute var value:Any;
  @:attribute var children:Children;

  override function render() return html(<>{children}</>);

  override function __setup(parent:Wire<Dynamic>, context:Context) {
    super.__setup(parent, context.getChild());
  }

  override function __update(
    attrs:Dynamic, 
    children:Array<VNode>,
    later:Signal<Any>
  ) {
    __context.set(id, value);
    super.__update(attrs, children, later);
  }

}
