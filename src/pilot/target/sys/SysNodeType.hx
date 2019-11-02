package pilot.target.sys;

import pilot.diff.*;

class SysNodeType<Attrs:{}> implements NodeType<Attrs, Node> {

  static final tags:Map<String, SysNodeType<Dynamic>> = [];

  static public function get(name:String):SysNodeType<Dynamic> {
    if (!tags.exists(name)) {
      tags.set(name, new SysNodeType(name));
    } 
    return tags.get(name);
  }

  final name:String;
  // todo: handle svg

  public function new(name) {
    this.name = name;
  }

  public function create(attrs:Attrs):Node {
    var node = new Node(name);
    Differ.patchObject(cast {}, attrs, setAttribute.bind(cast node));
    return node;
  }

  public function update(node:Node, oldAttrs:Attrs, newAttrs:Attrs):Void {
    Differ.patchObject(oldAttrs, newAttrs, setAttribute.bind(cast node));
  }

  function setAttribute(node:Node, key:String, oldValue:Dynamic, newValue:Dynamic) {
    if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
      // noop
    } else if (newValue == null || newValue == false) {
      node.removeAttribute(key);
    } else if (newValue == true) {
      node.setAttribute(key, key);
    } else {
      node.setAttribute(key, newValue);
    }
  }
  
}
