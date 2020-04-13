package pilot;

final class Provider<T> extends Component {

  @:attribute var id:String;
  @:attribute var value:T;
  @:attribute var children:Children;

  override function render() return html(<>{children}</>);

  override function __update(attrs:Dynamic, ?_:Array<VNode>, context:Context<Dynamic>, parent:Component) {
    __context = context.getChild();
    __context.set(id, value);
    super.__update(attrs, _, __context, parent);
  }

}
