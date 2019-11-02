package pilot.target.dom;

import js.Browser;
import js.html.Node;
import js.html.Element;
import pilot.diff.*;

class DomNodeType<Attrs:{}> implements NodeType<Attrs, Node> {

  static final tags:Map<String, DomNodeType<Dynamic>> = [];

  static public function get(name:String):DomNodeType<Dynamic> {
    if (!tags.exists(name)) {
      tags.set(name, new DomNodeType(name));
    } 
    return tags.get(name);
  }

  final name:String;
  // todo: handle svg

  public function new(name) {
    this.name = name;
  }

  public function create(attrs:Attrs):Node {
    var node = Browser.document.createElement(name);
    Differ.patchObject(cast {}, attrs, setAttribute.bind(cast node));
    return node;
  }

  public function update(node:Node, oldAttrs:Attrs, newAttrs:Attrs):Void {
    Differ.patchObject(oldAttrs, newAttrs, setAttribute.bind(cast node));
  }

  function setAttribute(el:Element, key:String, oldValue:Dynamic, newValue:Dynamic) {
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
  
}
