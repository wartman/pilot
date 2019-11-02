package pilot;

import pilot.diff.*;
import pilot.diff.NodeType as NodeTypeBase;

class NodeType<Attrs:{}> implements NodeTypeBase<Attrs, Node> {

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

  public function create(attrs:Attrs):Node {
    #if js
      var node = js.Browser.document.createElement(name);
    #else
      var node = new Node(name);
    #end
    Differ.patchObject(cast {}, attrs, setAttribute.bind(cast node));
    return node;
  }

  public function update(node:Node, oldAttrs:Attrs, newAttrs:Attrs):Void {
    Differ.patchObject(oldAttrs, newAttrs, setAttribute.bind(cast node));
  }

  #if js
  
    function setAttribute(el:js.html.Element, key:String, oldValue:Dynamic, newValue:Dynamic) {
      switch key {
        case 'value' | 'selected' | 'checked':
          js.Syntax.code('{0}[{1}] = {2}', el, key, newValue);
        default: if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
          var ev = key.substr(2).toLowerCase();
          el.removeEventListener(ev, oldValue);
          if (newValue != null) el.addEventListener(ev, newValue);
        } else if (newValue == null || newValue == false) {
          el.removeAttribute(key);
        } else if (newValue == true) {
          el.setAttribute(key, key);
        } else {
          el.setAttribute(key, newValue);
        }
      }
    }
  
  #else

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

  #end
  
}
