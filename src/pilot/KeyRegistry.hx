package pilot;

class KeyRegistry implements Registry<Key, Wire<Dynamic>> {
  
  var strings:Map<String, Wire<Dynamic>>;
  var objects:Map<{}, Wire<Dynamic>>;

  public function new() {}

  public function put(?key:Key, value:Wire<Dynamic>):Void {
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

  public function pull(?key:Key):Wire<Dynamic> {
    if (key == null) return null;
    var map:Map<Dynamic, Wire<Dynamic>> = if (key.isString()) strings else objects;
    if (map == null) return null;
    var out = map.get(key);
    map.remove(key);
    return out;
  }

  public function exists(key:Key):Bool {
    var map:Map<Dynamic, Wire<Dynamic>> = if (key.isString()) strings else objects;
    if (map == null) return false;
    return map.exists(key);
  }

}
