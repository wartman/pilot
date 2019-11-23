package pilot;

class Context {

  final data:Map<String, Dynamic>;

  public function new(?initialData) {
    data = if (initialData != null) initialData else [];
  }

  public function get<T>(name:String, ?def:T):T {
    return if (data.exists(name)) data.get(name) else def;
  }

  inline public function set<T>(name:String, value:T) {
    data.set(name, value);
  }

  inline public function remove(name:String) {
    data.remove(name);
  }

  public function copy() {
    return new Context(data);
  }

}
