package pilot;

import pilot.core.NodeTypeRegistry;
import pilot.core.WireBase;

class NativeNode<Attrs:{}> extends WireBase<Attrs, RealNode> {
  
  final real:RealNode;
  final isSvg:Bool;

  public function new(real, isSvg = false) {
    this.real = real;
    this.isSvg = isSvg;
  }

  public function hydrate() {
    if (childList.length > 0) return;

    for (n in real.childNodes) {
      var isSvg = isSvg || n.nodeName == 'svg';
      var type = isSvg ? NodeType.getSvg(n.nodeName) : NodeType.get(n.nodeName);
      var nn = new NativeNode(n, isSvg);
      if (!types.exists(type)) {
        types.set(type, new NodeTypeRegistry());
      }
      types.get(type).put(null, nn);
      childList.push(nn);
      nn.hydrate();
    }
  }

  override function _pilot_getReal():RealNode {
    return real;
  }

  override function _pilot_appendChildReal(child:RealNode) {
    if (child == null) return;
    real.appendChild(child);
  }

  override function _pilot_removeChildReal(child:RealNode) {
    real.removeChild(child);
  }

  override function _pilot_removeReal() {
    if (real.parentNode != null) {
      real.parentNode.removeChild(real);
    }
  }

  #if js
    
    override function applyAttribute(key:String, oldValue:Dynamic, newValue:Dynamic) {
      var el:js.html.Element = cast real;
      switch key {
        case 'value' | 'selected' | 'checked' if (!isSvg):
          js.Syntax.code('{0}[{1}] = {2}', el, key, newValue);
        case 'viewBox' if (isSvg):
          if (newValue == null) {
            el.removeAttributeNS(Dom.SVG_NS, key);
          } else {
            el.setAttributeNS(Dom.SVG_NS, key, newValue);
          }
        case 'xmlns' if (isSvg):
        case _ if (!isSvg && js.Syntax.code('{0} in {1}', key, el)):
          js.Syntax.code('{0}[{1}] = {2}', el, key, newValue);
        default: 
          if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
            var ev = key.substr(2).toLowerCase();
            el.removeEventListener(ev, oldValue);
            if (newValue != null) el.addEventListener(ev, newValue);
          } else if (newValue == null || (Std.is(newValue, Bool) && newValue == false)) {
            el.removeAttribute(key);
          } else if (Std.is(newValue, Bool) && newValue == true) {
            el.setAttribute(key, key);
          } else {
            el.setAttribute(key, newValue);
          }
      }
    }

  #else

    override function applyAttribute(key:String, oldValue:Dynamic, newValue:Dynamic) {
      if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
        // noop
      } else if (newValue == null || newValue == false) {
        real.removeAttribute(key);
      } else if (newValue == true) {
        real.setAttribute(key, key);
      } else {
        real.setAttribute(key, newValue);
      }
    }

  #end

}