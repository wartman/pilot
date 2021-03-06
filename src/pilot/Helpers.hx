package pilot;

import haxe.ds.Option;

class Helpers {

  #if js
    static final hasRaf:Bool = js.Syntax.code("typeof window != 'undefined' && 'requestAnimationFrame' in window");
  #end
  
  public static function later(exec:()->Void) {
    #if js
    if (hasRaf)
      js.Syntax.code('window.requestAnimationFrame({0})', _ -> exec());
    else
    #end
      haxe.Timer.delay(() -> exec(), 10);
  }

  public static function commitComponentEffects(effects:Array<()->Void>) {
    for (cb in effects) cb();
  }

  public static function createPreviousResolver<Node>(before:Null<WireCache<Node>>):(type:WireType<Dynamic>, key:Null<Key>)->Option<Wire<Node, Dynamic>> {
    if (before == null) {
      return (_, _) -> None;
    }
    return (type, key) -> {
      if (!before.types.exists(type)) return None;
      return switch before.types.get(type) {
        case null: None;
        case t: switch t.pull(key) {
          case null: None;
          case v: Some(v);
        }
      }
    }
  }

}
