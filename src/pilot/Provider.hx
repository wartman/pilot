package pilot;

final class Provider<T> extends Component {

  @:attribute var id:String;
  @:attribute var value:Dynamic;
  @:attribute var children:Children;

  override function render() return html(<>{children}</>);

  override function __update(
    attrs:Dynamic, 
    children:Array<VNode>,
    context:Context,
    later:Array<()->Void>  
  ) {
    var subContext = context.copy();
    subContext.set(id, value);
    super.__update(attrs, children, subContext, later);
  }

}
