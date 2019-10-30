package pilot2.target.dom;

import js.Browser;
import js.html.Node;
import js.html.Element;
import pilot2.diff.*;

using Reflect;

class DomNodeType<Attrs:{}> implements NodeType<Attrs, Node> {

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

  public function setAttribute(el:Element, key:String, oldValue:Dynamic, newValue:Dynamic) {
    if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
      var ev = key.substr(2).toLowerCase();
      el.removeEventListener(ev, oldValue);
      if (newValue != null) el.addEventListener(ev, newValue);
    } else if (newValue == null) {
      el.removeAttribute(key);
    } else {
      el.setAttribute(key, newValue);
    }
  }
  
}
