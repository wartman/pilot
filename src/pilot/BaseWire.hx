package pilot;

import pilot.html.*;

class BaseWire<Attrs:{}> implements Wire<Attrs> {

  var _pilot_attrs:Attrs;
  var _pilot_types:Map<WireType<Dynamic>, WireRegistry> = [];
  var _pilot_childList:Array<Wire<Dynamic>> = [];
  var _pilot_real:Node;

  public function _pilot_dispose():Void {
    if (_pilot_childList != null) {
      for (c in _pilot_childList) c._pilot_removeFrom(this);
    }
    _pilot_types = null;
    _pilot_childList = null;
  }

  public function _pilot_getReal():Node {
    return _pilot_real;
  }

  public function _pilot_insertInto(parent:Wire<Dynamic>):Void {
    parent._pilot_getReal().appendChild(_pilot_getReal());
  }

  public function _pilot_removeFrom(parent:Wire<Dynamic>):Void {
    parent._pilot_getReal().removeChild(_pilot_getReal());
    _pilot_dispose();
  }

  public function _pilot_update(newAttrs:Attrs, children:Array<VNode>, context:Context):Void {
    _pilot_updateAttributes(newAttrs, context);
    _pilot_updateChildren(children, context);
  }

  function _pilot_updateAttributes(newAttrs:Attrs, context:Context) {
    throw 'not implemented';
  }

  function _pilot_updateChildren(children:Array<VNode>, context:Context):Void {
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

      case VNative(type, attrs, children, key, ref): switch _pilot_resolveChildNode(type, key) {
        case null:
          var node = type._pilot_create(attrs, context);
          node._pilot_insertInto(this);
          node._pilot_update(attrs, children, context);
          add(key, type, node);
          if (ref != null) ref(node._pilot_getReal());
        case previous:
          previous._pilot_update(attrs, children, context);
          add(key, type, previous);
      }

      case VComponent(type, attrs, key): switch _pilot_resolveChildNode(type, key) {
        case null:
          var node = type._pilot_create(attrs, context);
          node._pilot_insertInto(this);
          node._pilot_update(attrs, [], context);
          add(key, type, node);
        case previous:
          previous._pilot_update(attrs, [], context);
          add(key, type, previous);
      }

      case VFragment(children):
        process(children);
    }

    process(children);

    if (_pilot_childList != null && _pilot_childList.length > 0) {
      for (node in _pilot_childList) {
        node._pilot_removeFrom(this);
      }
    }

    _pilot_types = newTypes;
    _pilot_childList = newChildList;
  }

  function _pilot_resolveChildNode(type:WireType<Dynamic>, ?key:Key) {
    var registry = _pilot_types.get(type);
    if (registry == null) return null;
    var n = registry.pull(key);
    _pilot_childList.remove(n);
    return n;
  }

}
