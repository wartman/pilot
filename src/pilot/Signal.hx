package pilot;

class Signal<T> {
  
  #if js
    static final hasRaf:Bool = js.Syntax.code("typeof window != 'undefined' && 'requestAnimationFrame' in window");
  #end

  static public inline function createVoidSignal():Signal<Any> {
    return new Signal();
  }

  var subscriptions:Array<SignalSubscription<T>> = [];

  public function new() {}

  public inline function add(listener:SignalListener<T>) {
    return __add(listener, false);
  }

  public inline function addOnce(listener:SignalListener<T>) {
    return __add(listener, true);
  }

  function __add(listener:SignalListener<T>, once:Bool) {
    var sub = new SignalSubscription(listener, this, once);
    subscriptions.push(sub);
    return sub;
  }

  public function remove(listener:SignalListener<T>) {
    subscriptions = subscriptions.filter(s -> s.listener != listener);
  }

  public function dispatch(data:T) {
    if (subscriptions.length == 0) return;
    for (s in subscriptions.slice(0, subscriptions.length)) s.invoke(data);
  }

  public function enqueue(data:T) {
    #if js
      if (hasRaf)
        js.Browser.window.requestAnimationFrame(_ -> dispatch(data));
      else
    #end
      haxe.Timer.delay(() -> dispatch(data), 10);
  }

  public function clear() {
    for (s in subscriptions.slice(0, subscriptions.length)) s.cancel();
  }

}

typedef SignalListener<T> = (data:T)->Void; 

@:forward(listener, onlyOnce)
abstract SignalSubscription<T>({ 
  listener:SignalListener<T>,
  signal:Signal<T>,
  onlyOnce:Bool
}) {

  public inline function new(listener, signal, onlyOnce) {
    this = {
      listener: listener,
      signal: signal,
      onlyOnce: onlyOnce
    };
  }

  public inline function invoke(data:T) {
    this.listener(data);
    if (this.onlyOnce) cancel();
  }

  public inline function cancel() {
    this.signal.remove(this.listener);
  }

}
