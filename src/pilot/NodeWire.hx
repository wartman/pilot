package pilot;

class NodeWire<Attrs:{}> extends BaseWire<Attrs> {

  final isSvg:Bool;

  public function new(real, initialAttrs:Attrs, context:Context, isSvg = false) {
    this.isSvg = isSvg;
    _pilot_real = real;
    _pilot_updateAttributes(initialAttrs, context);
  }

  public function hydrate(context:Context) {
    if (_pilot_childList.length > 0) return;

    for (n in _pilot_real.childNodes) {
      var isSvg = isSvg || n.nodeName == 'svg';
      var type = isSvg ? NodeType.getSvg(n.nodeName) : NodeType.get(n.nodeName);
      var nn = new NodeWire(n, {}, context, isSvg);
      if (!_pilot_types.exists(type)) {
        _pilot_types.set(type, new WireRegistry());
      }
      _pilot_types.get(type).put(null, nn);
      _pilot_childList.push(nn);
      nn.hydrate(context);
    }
  }

  #if js
    
    override function _pilot_applyAttribute(key:String, oldValue:Dynamic, newValue:Dynamic) {
      var el = _pilot_real.toElement();
      switch key {
        case 'value' | 'selected' | 'checked' if (!isSvg):
          js.Syntax.code('{0}[{1}] = {2}', el, key, newValue);
        case 'viewBox' if (isSvg):
          if (newValue == null) {
            el.removeAttributeNS(Node.SVG_NS, key);
          } else {
            el.setAttributeNS(Node.SVG_NS, key, newValue);
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

    override function _pilot_applyAttribute(key:String, oldValue:Dynamic, newValue:Dynamic) {
      if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
        // noop
      } else if (newValue == null || newValue == false) {
        _pilot_real.removeAttribute(key);
      } else if (newValue == true) {
        _pilot_real.setAttribute(key, key);
      } else {
        _pilot_real.setAttribute(key, newValue);
      }
    }

  #end

}
