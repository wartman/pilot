package pilot;

final class Provider<T> extends Component {

  @:attribute var id:String;
  @:attribute( 
    effect = __context.set(id, value) 
  ) var value:T;
  @:attribute var children:Children;

  override function render():VNode return VFragment(children);

  override function __update(
    attrs:Dynamic, 
    ?_:Array<VNode>, 
    context:Context<Dynamic>, 
    parent:Component,
    effectQueue:Array<()->Void>
  ) {
    __context = context.getChild();
    super.__update(attrs, _, __context, parent, effectQueue);
  }

  override function __hydrate(
    cursor:Cursor<Dynamic>, 
    attrs:Dynamic, 
    ?_:Array<VNode>,
    parent:Component,
    context:Context<Dynamic>,
    effectQueue:Array<()->Void>
  ) {
    __context = context.getChild();
    super.__hydrate(cursor, attrs, _, parent, __context, effectQueue);
  }
  
}
