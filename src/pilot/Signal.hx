package pilot;

class Signal<T> {
  
  #if js
    static final hasRaf:Bool = js.Syntax.code("typeof window != 'undefined' && 'requestAnimationFrame' in window");
  #end

  var subscriptions:Array<SignalSubscription<T>> = [];

  public function new() {}

  public function add(listener:SignalListener<T>) {
    var sub = new SignalSubscription(listener, this, false);
    subscriptions.push(sub);
    return sub;
  }

  public function addOnce(listener:SignalListener<T>) {
    var sub = new SignalSubscription(listener, this, true);
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
    #if js
      if (hasRaf)
        js.Browser.window.requestAnimationFrame(_ -> dispatch(data));
      else
    #end
      haxe.Timer.delay(() -> dispatch(data), 10);
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
