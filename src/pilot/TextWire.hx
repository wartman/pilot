package pilot;

import pilot.dom.*;

class TextWire implements Wire<String> {
  
  final node:Text;

  public function new(content) {
    node = Document.root.createTextNode(content);
  }

  public function __getNode():Node {
    return node;
  }

  public function __getCursor():Cursor {
    return null;
  }
  
  public function __getFirstNode():Node {
    return node;
  }

  public function __getLastNode():Node {
    return node;
  }

  public function __isUpdating() {
    return false;
  }

  public function __dispose():Void {
    // noop
  }

  public function __insertInto(parent:Wire<Dynamic>) {
    if (parent.__isUpdating()) {
      var cursor = parent.__getCursor();
      if (cursor.getCurrent() == node) {
        cursor.step();
      } else {
        cursor.insert(node);
      }
    } else {
      parent.__getNode().appendChild(node);
    }
  }
  
  public function __removeFrom(parent:Wire<Dynamic>) {
    if (parent.__isUpdating() && parent.__getCursor().getCurrent() == node) {
      parent.__getCursor().remove();
    } else {
      parent.__getNode().removeChild(node);
    }
    __dispose();
  }
  
  public function __update(attrs:String, children:Array<VNode>, context:Context):Void {
    if (attrs == node.textContent) return;
    node.textContent = attrs;
  }

}
