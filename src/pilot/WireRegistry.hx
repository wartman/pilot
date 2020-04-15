package pilot;

class WireRegistry<Node> implements Registry<Key, Wire<Node, Dynamic>> {

  var keyed:KeyRegistry<Node>;
  var unkeyed:Array<Wire<Node, Dynamic>>;

  public function new() {}

  public function put(?key:Key, value:Wire<Node, Dynamic>):Void {
    if (key == null) {
      if (unkeyed == null) unkeyed = [];
      unkeyed.push(value);
    } else {
      if (keyed == null) keyed = new KeyRegistry();
      keyed.put(key, value);
    }
  }

  public function pull(?key:Key):Wire<Node, Dynamic> {
    if (key == null) {
      return if (unkeyed != null) unkeyed.shift() else null;
    } else {
      return if (keyed != null) keyed.pull(key) else null;
    }
  }

  public function exists(key:Key):Bool {
    return if (keyed == null) false else keyed.exists(key);
  }

  public inline function each(cb:(wire:Wire<Node, Dynamic>)->Void) {
    if (keyed != null) keyed.each(cb);
    if (unkeyed != null) for (k in unkeyed) cb(k);
  }

}
