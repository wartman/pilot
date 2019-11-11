package pilot.core;

class WireBase<Attrs:{}, Real:{}> implements Wire<Attrs, Real> {
  
  var attrs:Attrs;
  var types:Map<NodeType<Dynamic, Real>, NodeTypeRegistry<Real>> = [];
  var childList:Array<Wire<Dynamic, Real>> = [];

  public function _pilot_getReal():Real {
    return null;
  }

  public function _pilot_appendChild(child:Wire<Dynamic, Real>) {
    if (child == null) return;
    _pilot_appendChildReal(child._pilot_getReal());
  }

  public function _pilot_appendChildReal(child:Real) {
    throw 'not implemented';
  }

  public function _pilot_removeChild(child:Wire<Dynamic, Real>) {
    _pilot_removeChildReal(child._pilot_getReal());
    child._pilot_dispose();
  }

  function _pilot_removeChildReal(child:Real) {
    throw 'not implemented';
  }

  function applyAttribute(key:String, oldValue:Dynamic, newValue:Dynamic) {
    throw 'not implemented';
  }

  public function _pilot_dispose() {
    for (c in childList) c._pilot_dispose();
    types = null;
    childList = null;
    _pilot_removeReal();
  }

  function _pilot_removeReal() {
    throw 'not implemented';
  }

  public function _pilot_update(newAttrs:Attrs) {
    var previous:Attrs = attrs;
    if (previous == null) previous = cast {};
    attrs = newAttrs;
    Util.diffObject(previous, newAttrs, applyAttribute);
  }

  public function _pilot_updateChildren(children:Array<VNode<Real>>) {
    var newChildList:Array<Wire<Dynamic, Real>> = [];
    var newTypes:Map<NodeType<Dynamic, Real>, NodeTypeRegistry<Real>> = [];

    function add(key:Key, type:NodeType<Dynamic, Real>, wire:Wire<Dynamic, Real>) {
      if (!newTypes.exists(type)) {
        newTypes.set(type, new NodeTypeRegistry());
      }
      newTypes.get(type).put(key, wire);
      newChildList.push(wire);
    }

    function process(nodes:Array<VNode<Real>>) for (n in nodes) switch n {
      case null:

      case VNative(type, attrs, children, key): switch resolveChildNode(type, key) {
        case null:
          var node = type._pilot_create(attrs);
          _pilot_appendChild(node);
          node._pilot_updateChildren(children);
          add(key, type, node);
        case previous:
          previous._pilot_update(attrs);
          previous._pilot_updateChildren(children);
          add(key, type, previous);
      }

      case VComponent(type, attrs, key): switch resolveChildNode(type, key) {
        case null:
          var node = type._pilot_create(attrs);
          _pilot_appendChild(node);
          add(key, type, node);
        case previous:
          previous._pilot_update(attrs);
          add(key, type, previous);
      }

      case VFragment(children):
        process(children);
    }

    process(children);

    if (childList.length > 0) {
      for (node in childList) {
        _pilot_removeChild(node);
      }
    }

    types = newTypes;
    childList = newChildList;
  }

  function resolveChildNode(type:NodeType<Dynamic, Real>, ?key:Key) {
    var registry = types.get(type);
    if (registry == null) return null;
    var n = registry.pull(key);
    childList.remove(n);
    return n;
  }

}