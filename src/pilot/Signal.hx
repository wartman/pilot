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
    for (s in subscriptions) s.invoke(data);
    subscriptions = subscriptions.filter(s -> !s.onlyOnce);
  }

  public function enqueue(data:T) {
    var cbs = subscriptions.copy();
    subscriptions = [];
    function handle() {
      for (s in cbs) s.invoke(data);
      subscriptions = cbs.filter(s -> !s.onlyOnce).concat(subscriptions);
    }
    #if js
      if (hasRaf)
        js.Browser.window.requestAnimationFrame(_ -> handle());
      else
    #end
      haxe.Timer.delay(() -> handle(), 10);
  }

  public function clear() {
    for (s in subscriptions) s.cancel();
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
  }

  public inline function cancel() {
    this.signal.remove(this.listener);
  }

}
