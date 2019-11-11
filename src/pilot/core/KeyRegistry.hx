package pilot.core;

class KeyRegistry<Real:{}> implements Registry<Key, Wire<Dynamic, Real>> {
  
  var strings:Map<String, Wire<Dynamic, Real>>;
  var objects:Map<{}, Wire<Dynamic, Real>>;

  public function new() {}

  public function put(?key:Key, value:Wire<Dynamic, Real>):Void {
    if (key == null) {
      throw 'Key cannot be null';
    } if (key.isString()) {
      if (strings == null) strings = [];
      strings.set(cast key, value);
    } else {
      if (objects == null) objects = [];
      objects.set(key, value);
    }
  }

  public function pull(?key:Key):Wire<Dynamic, Real> {
    if (key == null) return null;
    var map:Map<Dynamic, Wire<Dynamic, Real>> = if (key.isString()) strings else objects;
    if (map == null) return null;
    var out = map.get(key);
    map.remove(key);
    return out;
  }

  public function exists(key:Key):Bool {
    var map:Map<Dynamic, Wire<Dynamic, Real>> = if (key.isString()) strings else objects;
    if (map == null) return false;
    return map.exists(key);
  }

  // public function dispose() {
  //   if (strings != null) for (_ => wire in strings) wire._pilot_dispose();
  //   if (objects != null) for (_ => wire in objects) wire._pilot_dispose();
  //   strings = null;
  //   objects = null; 
  // }

}
