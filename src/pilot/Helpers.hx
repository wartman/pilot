package pilot;

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

}
