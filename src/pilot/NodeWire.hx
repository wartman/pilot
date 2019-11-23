package pilot;

class NodeWire<Attrs:{}> implements Wire<Attrs> {

  var attrs:Attrs;
  var types:Map<WireType<Dynamic>, WireRegistry> = [];
  var childList:Array<Wire<Dynamic>> = [];
  var real:Node;
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
      var nn = new NodeWire(n, isSvg);
      if (!types.exists(type)) {
        types.set(type, new WireRegistry());
      }
      types.get(type).put(null, nn);
      childList.push(nn);
      nn.hydrate();
    }
  }

  public function _pilot_dispose():Void {
    if (childList != null) {
      for (c in childList) c._pilot_removeFrom(this);
    }
    types = null;
    childList = null;
  }

  public function _pilot_getReal():Node {
    return real;
  }

  public function _pilot_insertInto(parent:Wire<Dynamic>):Void {
    parent._pilot_getReal().appendChild(_pilot_getReal());
  }

  public function _pilot_removeFrom(parent:Wire<Dynamic>):Void {
    parent._pilot_getReal().removeChild(_pilot_getReal());
    _pilot_dispose();
  }

  public function _pilot_update(newAttrs:Attrs, context:Context):Void {
    var previous:Attrs = attrs;
    if (previous == null) previous = cast {};
    attrs = newAttrs;
    Util.diffObject(previous, newAttrs, applyAttribute);
  }

  public function _pilot_updateChildren(children:Array<VNode>, context:Context):Void {
    var newChildList:Array<Wire<Dynamic>> = [];
    var newTypes:Map<WireType<Dynamic>, WireRegistry> = [];

    function add(key:Key, type:WireType<Dynamic>, wire:Wire<Dynamic>) {
      if (!newTypes.exists(type)) {
        newTypes.set(type, new WireRegistry());
      }
      newTypes.get(type).put(key, wire);
      newChildList.push(wire);
    }

    function process(nodes:Array<VNode>) for (n in nodes) switch n {
      case null:

      case VNative(type, attrs, children, key): switch resolveChildNode(type, key) {
        case null:
          var node = type._pilot_create(attrs, context);
          node._pilot_insertInto(this);
          node._pilot_updateChildren(children, context);
          add(key, type, node);
        case previous:
          previous._pilot_update(attrs, context);
          previous._pilot_updateChildren(children, context);
          add(key, type, previous);
      }

      case VComponent(type, attrs, key): switch resolveChildNode(type, key) {
        case null:
          var node = type._pilot_create(attrs, context);
          node._pilot_insertInto(this);
          add(key, type, node);
        case previous:
          previous._pilot_update(attrs, context);
          add(key, type, previous);
      }

      case VFragment(children):
        process(children);
    }

    process(children);

    if (childList != null && childList.length > 0) {
      for (node in childList) {
        node._pilot_removeFrom(this);
      }
    }

    types = newTypes;
    childList = newChildList;
  }

  function resolveChildNode(type:WireType<Dynamic>, ?key:Key) {
    var registry = types.get(type);
    if (registry == null) return null;
    var n = registry.pull(key);
    childList.remove(n);
    return n;
  }

  #if js
    
    function applyAttribute(key:String, oldValue:Dynamic, newValue:Dynamic) {
      var el = real.toElement();
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

    function applyAttribute(key:String, oldValue:Dynamic, newValue:Dynamic) {
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
