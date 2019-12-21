package pilot;

import pilot.dom.*;

class NodeType<Attrs:{}> {

  inline public static final SVG_NS = 'http://www.w3.org/2000/svg';
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
    var doc = Document.root;
    return new NodeWire(
      isSvg 
        ? doc.createElementNS(SVG_NS, name) 
        : doc.createElement(name),
      attrs,
      context,
      isSvg
    );
  }

}
