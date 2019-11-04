package pilot;

import pilot.core.Wire;
import pilot.core.VNode;

class TextNode implements Wire<String, RealNode> {

  public final real:RealNode;

  public function new(content:String) {
    real = Dom.createTextNode(content);
  }

  public function _pilot_appendChild(child:Wire<Dynamic, RealNode>):Void {
    throw 'Cannot add children to a text node';
  }

  public function _pilot_removeChild(child:Wire<Dynamic, RealNode>):Void {
    throw 'Text node does not have children';  
  }

  public function _pilot_getReal():RealNode {
    return real;
  }

  public function _pilot_dispose():Void {
    if (real.parentNode != null) {
      real.parentNode.removeChild(real);
    }
  }

  public function _pilot_update(attrs:String):Void {
    if (attrs == real.textContent) return;
    real.textContent = attrs;
  }

  public function _pilot_updateChildren(children:Array<VNode<RealNode>>):Void {
    // noop
  }
  
}
