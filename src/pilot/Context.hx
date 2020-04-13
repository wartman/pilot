package pilot;

class Context<Node:{}> {
  
  public final engine:Engine<Node>;
  // public final styles:StyleManager;
  final data:Map<String, Dynamic> = [];
  final parent:Context<Node>;
  
  public function new(engine, ?parent) {
    this.engine = engine;
    this.parent = parent;
  }

  public function get<T>(name:String, ?def:T):T {
    return if (data.exists(name)) 
      data.get(name)
    else if (parent != null)
      parent.get(name, def); 
    else 
      def;
  }

  inline public function set<T>(name:String, value:T) {
    data.set(name, value);
  }

  inline public function remove(name:String) {
    data.remove(name);
  }

  public function getChild<Node:{}>(?engine:Engine<Node>):Context<Node> {
    return new Context(engine == null ? cast this.engine : engine, cast this);
  }

}
