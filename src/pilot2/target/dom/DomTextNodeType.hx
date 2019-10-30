package pilot2.target.dom;

import js.Browser;
import js.html.Node;
import pilot2.diff.NodeType;

class DomTextNodeType implements NodeType<String, Node> {
  
  public function new() {}

  public function create(attrs:String):Node {
    return Browser.document.createTextNode(attrs);
  }

  public function update(node:Node, oldAttrs:String, newAttrs:String) {
    if (oldAttrs != newAttrs) {
      node.textContent = newAttrs;
    }
  }

}
