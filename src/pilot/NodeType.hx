package pilot;

import haxe.ds.Map;

class NodeType<Attrs:{}> {
  
  static final tags:Map<String, NodeType<Dynamic>> = [];

  public static function get<Node, Attrs:{}>(tag:String):NodeType<Attrs> {
    if (!tags.exists(tag)) {
      tags.set(tag, new NodeType(tag));
    } 
    return cast tags.get(tag);
  }

  static public function getSvg<Node, Attrs:{}>(name:String):NodeType<Attrs> {
    if (!tags.exists(name)) {
      tags.set(name, new NodeType(name, true));
    } 
    return cast tags.get(name);
  }
  
  final tag:String;
  final isSvg:Bool;

  public function new(tag, isSvg = false) {
    this.tag = tag;
    this.isSvg = isSvg;
  }

  public function __create<Node>(props:Attrs, context:Context<Node>):Wire<Node, Attrs> {
    var node = isSvg 
      ? context.engine.createSvgNode(tag)
      : context.engine.createNode(tag);
    return new NodeWire(node, context);
  }
  
  public function __hydrate<Node>(node:Node, props:Attrs, context:Context<Node>):Wire<Node, Attrs> {
    return new NodeWire(node, context);
  }
  
}
