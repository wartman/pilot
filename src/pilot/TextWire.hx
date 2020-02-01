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

  public function __dispose():Void {
    // noop
  }

  public function __insertInto(parent:Wire<Dynamic>) {
    parent.__getReal().appendChild(real);
  }
  
  public function __removeFrom(parent:Wire<Dynamic>) {
    parent.__getReal().removeChild(real);
    __dispose();
  }
  
  public function __update(attrs:String, children:Array<VNode>, context:Context):Void {
    if (attrs == real.textContent) return;
    real.textContent = attrs;
  }

}
