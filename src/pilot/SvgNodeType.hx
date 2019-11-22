package pilot;

import pilot.core.Wire;
import pilot.core.Context;

class SvgNodeType<Attrs:{}> {
  
  static final tags:Map<String, SvgNodeType<Dynamic>> = [];

  static public function get(name:String):SvgNodeType<Dynamic> {
    if (!tags.exists(name)) {
      tags.set(name, new SvgNodeType(name));
    } 
    return tags.get(name);
  }

  final name:String;

  public function new(name) {
    this.name = name;
  }

  public function _pilot_create(attrs:Attrs, context:Context):Wire<Attrs, RealNode> {
    var node = new NativeNode(Dom.createSvgNode(name), true);
    node._pilot_update(attrs, context);
    return node;
  }

}
