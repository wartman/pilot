package pilot;

import pilot.dom.*;

class BaseWire<Attrs:{}> implements Wire<Attrs> {

  var __attrs:Attrs;
  var __types:Map<WireType<Dynamic>, WireRegistry> = [];
  var __childList:Array<Wire<Dynamic>> = [];
  var __real:Node;

  public function __dispose():Void {
    if (__childList != null) {
      for (c in __childList) c.__removeFrom(this);
    }
    __types = null;
    __childList = null;
  }

  public function __getReal():Node {
    return __real;
  }

  public function __insertInto(parent:Wire<Dynamic>):Void {
    parent.__getReal().appendChild(__getReal());
  }

  public function __removeFrom(parent:Wire<Dynamic>):Void {
    parent.__getReal().removeChild(__getReal());
    __dispose();
  }

  public function __update(newAttrs:Attrs, children:Array<VNode>, context:Context):Void {
    __updateAttributes(newAttrs, context);
    __updateChildren(children, context);
  }

  function __updateAttributes(newAttrs:Attrs, context:Context) {
    throw 'not implemented';
  }

  function __updateChildren(children:Array<VNode>, context:Context):Void {
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

      case VNative(type, attrs, children, key, ref): switch __resolveChildNode(type, key) {
        case null:
          var node = type.__create(attrs, context);
          node.__insertInto(this);
          node.__update(attrs, children, context);
          add(key, type, node);
          if (ref != null) ref(node.__getReal());
        case previous:
          previous.__update(attrs, children, context);
          add(key, type, previous);
      }

      case VComponent(type, attrs, key): switch __resolveChildNode(type, key) {
        case null:
          var node = type.__create(attrs, context);
          node.__insertInto(this);
          node.__update(attrs, [], context);
          add(key, type, node);
        case previous:
          previous.__update(attrs, [], context);
          add(key, type, previous);
      }

      case VFragment(children):
        process(children);
    }

    process(children);

    if (__childList != null && __childList.length > 0) {
      for (node in __childList) {
        node.__removeFrom(this);
      }
    }

    __types = newTypes;
    __childList = newChildList;
  }

  function __resolveChildNode(type:WireType<Dynamic>, ?key:Key) {
    var registry = __types.get(type);
    if (registry == null) return null;
    var n = registry.pull(key);
    __childList.remove(n);
    return n;
  }

}
