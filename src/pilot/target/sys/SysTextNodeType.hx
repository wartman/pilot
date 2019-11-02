package pilot.target.sys;

import pilot.diff.NodeType;

class SysTextNodeType implements NodeType<String, Node> {
  
  static public final inst = new SysTextNodeType();

  public function new() {}

  public function create(attrs:String):Node {
    var node = new Node(Node.TEXT);
    node.textContent = attrs;
    return node;
  }

  public function update(node:Node, oldAttrs:String, newAttrs:String) {
    if (oldAttrs != newAttrs) {
      node.textContent = newAttrs;
    }
  }

}
