package pilot;

import pilot.core.Wire;
import pilot.core.Context;

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

  public function _pilot_create(attrs:Attrs, context:Context):Wire<Attrs, RealNode> {
    var node = new NativeNode(Dom.createNode(name));
    node._pilot_update(attrs, context);
    return node;
  }

}
