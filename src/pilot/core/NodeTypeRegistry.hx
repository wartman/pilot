package pilot.core;

class NodeTypeRegistry<Real:{}> implements Registry<Key, Wire<Dynamic, Real>> {

  var keyed:KeyRegistry<Real>;
  var unkeyed:Array<Wire<Dynamic, Real>>;

  public function new() {}

  public function put(?key:Key, value:Wire<Dynamic, Real>):Void {
    if (key == null) {
      if (unkeyed == null) unkeyed = [];
      unkeyed.push(value);
    } else {
      if (keyed == null) keyed = new KeyRegistry();
      keyed.put(key, value);
    }
  }

  public function pull(?key:Key):Wire<Dynamic, Real> {
    if (key == null) {
      return if (unkeyed != null) unkeyed.shift() else null;
    } else {
      return if (keyed != null) keyed.pull(key) else null;
    }
  }

  public function exists(key:Key):Bool {
    return if (keyed == null) false else keyed.exists(key);
  }

  // public function dispose() {
  //   for (wire in unkeyed) wire._pilot_dispose();
  //   unkeyed = [];
  //   keyed.dispose();
  // }

}
