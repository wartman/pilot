package pilot;

abstract Later(Array<()->Void>) {

  public inline function new() {
    this = [];
  }

  public inline function add(cb:()->Void) {
    this.push(cb);
  }

  public inline function dispatch() {
    #if (js && !nodejs)
      js.Browser.window.requestAnimationFrame(_ -> for (cb in this) cb());
    #else
      haxe.Timer.delay(() -> for (cb in this) cb(), 10);
    #end
  }

}
