package pilot2;

class Scheduler {

  #if js
    static var hasRaf:Bool = js.Syntax.code("typeof window != 'undefined' && 'requestAnimationFrame' in window");
  #end

  public static function enqueue(cb:()->Void) {
    #if js
      if (hasRaf) {
        js.Browser.window.requestAnimationFrame(_ -> cb());
      } else {
        haxe.Timer.delay(cb, 0);
      }
    #else
      haxe.Timer.delay(cb, 0);
    #end
  }

}
