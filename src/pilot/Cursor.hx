package pilot;

import pilot.dom.*;

class Cursor {

  final parent:Node;
  var current:Node;

  public function new(parent, current) {
    this.parent = parent;
    this.current = current;
  }

  public function insert(node:Node):Bool {
    var wasInserted = node.parentNode != parent;
    parent.insertBefore(node, current);
    return wasInserted;
  }

  public function step() {
    return switch current {
      case null: false;
      case node: (current = node.nextSibling) != null;
    }
  }

  public function remove() {
    return switch current {
      case null: false;
      case node:
        current = node.nextSibling;
        parent.removeChild(node);
        true;
    }
  }

  public function sync(node:Node) {
    while (current != node) {
      if (!step()) break;
    }
  }

  public function getCurrent() {
    return current;
  }

}
