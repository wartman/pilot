package pilot;

abstract Later(Array<()->Void>) {

  #if js
    static final hasRaf:Bool = js.Syntax.code("typeof window != 'undefined' && 'requestAnimationFrame' in window");
  #end

  public inline function new() {
    this = [];
  }

  public inline function add(cb:()->Void) {
    this.push(cb);
  }

  public inline function enqueue() {
    #if js
      if (hasRaf)
        js.Browser.window.requestAnimationFrame(_ -> for (cb in this) cb());
      else
    #end
      haxe.Timer.delay(() -> for (cb in this) cb(), 10);
  }

}
