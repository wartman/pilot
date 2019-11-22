package pilot;

class NodeType<Attrs:{}> {
  
  static final tags:Map<String, NodeType<Dynamic>> = [];

  static public function get(name:String):NodeType<Dynamic> {
    if (!tags.exists(name)) {
      tags.set(name, new NodeType(name));
    } 
    return tags.get(name);
  }

  static public function getSvg(name:String):NodeType<Dynamic> {
    if (!tags.exists(name)) {
      tags.set(name, new NodeType(name, true));
    } 
    return tags.get(name);
  }

  final name:String;
  final isSvg:Bool;

  public function new(name, isSvg = false) {
    this.name = name;
    this.isSvg = isSvg;
  }

  public function _pilot_create(attrs:Attrs, context:Context):Wire<Attrs> {
    var node = new NodeWire(
      new Node(name, isSvg ? Svg : Native),
      isSvg
    );
    node._pilot_update(attrs, context);
    return node;
  }

}
