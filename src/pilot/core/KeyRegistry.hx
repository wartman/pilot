package pilot.core;

class KeyRegistry<T> implements Registry<Key, T> {
  
  var strings:Map<String, T>;
  var objects:Map<{}, T>;

  public function new() {}

  public function put(?key:Key, value:T):Void {
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

  public function pull(?key:Key):T {
    if (key == null) return null;
    var map:Map<Dynamic, T> = if (key.isString()) strings else objects;
    if (map == null) return null;
    var out = map.get(key);
    map.remove(key);
    return out;
  }

  public function exists(key:Key):Bool {
    var map:Map<Dynamic, T> = if (key.isString()) strings else objects;
    if (map == null) return false;
    return map.exists(key);
  }

}
