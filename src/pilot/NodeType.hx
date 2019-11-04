package pilot;

import pilot.core.Wire;

class NodeType<Attrs:{}> {
  
  static final tags:Map<String, NodeType<Dynamic>> = [];

  static public function get(name:String):NodeType<Dynamic> {
    if (!tags.exists(name)) {
      tags.set(name, new NodeType(name));
    } 
    return tags.get(name);
  }

  final name:String;
  // todo: handle svg

  public function new(name) {
    this.name = name;
  }

  public function _pilot_create(attrs:Attrs):Wire<Attrs, RealNode> {
    var node = new NativeNode(Dom.createNode(name));
    node._pilot_update(attrs);
    return node;
  }

}
