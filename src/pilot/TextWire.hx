package pilot;

class TextWire implements Wire<String> {
  
  final real:Node;

  public function new(content) {
    real = new Node(content, Text);
  }

  public function _pilot_getReal():Node {
    return real;
  }

  public function _pilot_dispose():Void {
    // noop
  }

  public function _pilot_insertInto(parent:Wire<Dynamic>) {
    parent._pilot_getReal().appendChild(real);
  }
  
  public function _pilot_removeFrom(parent:Wire<Dynamic>) {
    parent._pilot_getReal().removeChild(real);
    _pilot_dispose();
  }
  
  public function _pilot_update(attrs:String, children:Array<VNode>, context:Context):Void {
    if (attrs == real.textContent) return;
    real.textContent = attrs;
  }

}
