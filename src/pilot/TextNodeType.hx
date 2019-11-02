package pilot;

import pilot.diff.NodeType;

class TextNodeType implements NodeType<String, Node> {
  
  static public final inst = new TextNodeType();

  public function new() {}

  public function create(attrs:String):Node {
    #if js
      var node = js.Browser.document.createTextNode(attrs);
    #else
      var node = new Node(Node.TEXT);
      node.textContent = attrs;
    #end
    return node;
  }

  public function update(node:Node, oldAttrs:String, newAttrs:String) {
    if (oldAttrs != newAttrs) {
      node.textContent = newAttrs;
    }
  }

}
