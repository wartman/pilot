package pilot;

import pilot.dom.*;

class Cursor {

  public final parent:Node;
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

  public function getCurrent() {
    return current;
  }

  public function sync(
    nextNodes:Array<Node>, 
    previousCount:Int
  ) {
    var insertedCount = 0;
    var currentCount = 0;

    for (node in nextNodes) {
      currentCount++;
      if (getCurrent() == node) {
        step();
      } else if (insert(node)) {
        insertedCount++;
      }
    }

    var deleteCount = previousCount + insertedCount - currentCount;

    for (_ in 0...deleteCount) if (!remove()) break;
  }

}
