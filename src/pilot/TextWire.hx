package pilot;

import pilot.dom.*;

class TextWire implements Wire<String> {
  
  final node:Text;

  public function new(content) {
    node = Document.root.createTextNode(content);
  }

  public function __getNodes():Array<Node> {
    return [ node ];
  }

  public function __getCursor():Cursor {
    return null;
  }

  public function __setup(parent:Wire<Dynamic>) {
    // noop
  }

  public function __dispose():Void {
    // noop
  }
  
  public function __update(attrs:String, children:Array<VNode>, context:Context):Void {
    if (attrs == node.textContent) return;
    node.textContent = attrs;
  }

}
