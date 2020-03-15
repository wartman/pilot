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

  public function __getChildList():Array<Wire<Dynamic>> {
    return null;
  }
  
  public function __setChildList(childList:Array<Wire<Dynamic>>):Void {
    // noop
  }

  public function __getWireTypeRegistry():Map<WireType<Dynamic>, WireRegistry> {
    return null;
  }

  public function __setWireTypeRegistry(types:Map<WireType<Dynamic>, WireRegistry>):Void {
    // noop
  }

  public function __setup(parent:Wire<Dynamic>, context:Context) {
    // noop
  }

  public function __dispose():Void {
    // noop
  }
  
  public function __update(
    attrs:String, 
    children:Array<VNode>,
    later:Signal<Any>
  ):Void {
    if (attrs == node.textContent) return;
    node.textContent = attrs;
  }

}
