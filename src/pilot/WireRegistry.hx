package pilot;

class WireRegistry implements Registry<Key, Wire<Dynamic>> {

  var keyed:KeyRegistry;
  var unkeyed:Array<Wire<Dynamic>>;

  public function new() {}

  public function put(?key:Key, value:Wire<Dynamic>):Void {
    if (key == null) {
      if (unkeyed == null) unkeyed = [];
      unkeyed.push(value);
    } else {
      if (keyed == null) keyed = new KeyRegistry();
      keyed.put(key, value);
    }
  }

  public function pull(?key:Key):Wire<Dynamic> {
    if (key == null) {
      return if (unkeyed != null) unkeyed.shift() else null;
    } else {
      return if (keyed != null) keyed.pull(key) else null;
    }
  }

  public function exists(key:Key):Bool {
    return if (keyed == null) false else keyed.exists(key);
  }

}
