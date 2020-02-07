package pilot;

import pilot.dom.*;

class TextWire implements Wire<String> {
  
  final real:Text;

  public function new(content) {
    real = Document.root.createTextNode(content);
  }

  public function __getReal():Node {
    return real;
  }

  public function __getCursor():Cursor {
    return null;
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
      if (cursor.getCurrent() == real) {
        cursor.step();
      } else {
        cursor.insert(real);
      }
    } else {
      parent.__getReal().appendChild(real);
    }
  }
  
  public function __removeFrom(parent:Wire<Dynamic>) {
    if (parent.__isUpdating() && parent.__getCursor().getCurrent() == real) {
      parent.__getCursor().remove();
    } else {
      parent.__getReal().removeChild(real);
    }
    __dispose();
  }
  
  public function __update(attrs:String, children:Array<VNode>, context:Context):Void {
    if (attrs == real.textContent) return;
    real.textContent = attrs;
  }

}
