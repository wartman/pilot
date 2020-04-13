package pilot.platform.dom;

import js.html.Node;

class DomCursor implements Cursor<Node> {
  
  final parent:Node;
  var currentNode:Node;

  public function new(parent, currentNode) {
    this.parent = parent;
    this.currentNode = currentNode;
  }

  public function insert(node:Node):Bool {
    var wasInserted = node.parentNode != parent;
    parent.insertBefore(node, currentNode);
    return wasInserted;
  }

  public function step() {
    return switch currentNode {
      case null: false;
      case node: (currentNode = node.nextSibling) != null;
    }
  }

  public function delete() {
    return switch currentNode {
      case null: false;
      case node:
        currentNode = node.nextSibling;
        parent.removeChild(node);
        true;
    }
  }

  public function current() {
    return currentNode;
  }

}
