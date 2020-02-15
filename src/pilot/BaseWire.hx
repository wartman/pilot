package pilot;

import pilot.dom.*;
using pilot.DiffingTools;

class BaseWire<Attrs:{}> implements Wire<Attrs> {

  var __attrs:Attrs;
  var __types:Map<WireType<Dynamic>, WireRegistry> = [];
  var __childList:Array<Wire<Dynamic>> = [];
  
  public function __getNodes():Array<Node> {
    throw 'not implemented';
  }

  public function __setup(parent:Wire<Dynamic>):Void {
    // Noop
  }

  public function __update(
    attrs:Attrs,
    children:Array<VNode>,
    context:Context
  ) {
    throw 'Not implemented';
  }

  public function __dispose() {
    // noop;
  }

  public function __getCursor():Cursor {
    throw 'not implemented';
  }

  function __setChildren(nextNodes:Array<Node>, previousCount:Int) {
    var cursor = __getCursor();
    if (cursor == null) return;
    
    var insertedCount = 0;
    var currentCount = 0;

    for (node in nextNodes) {
      currentCount++;
      if (cursor.getCurrent() == node) {
        cursor.step();
      } else if (cursor.insert(node)) {
        insertedCount++;
      }
    }

    var deleteCount = previousCount + insertedCount - currentCount;

    for (_ in 0...deleteCount) if (!cursor.remove()) break;
  }

  function __updateChildren(
    children:Array<VNode>,
    context:Context
  ) {
    var newChildList:Array<Wire<Dynamic>> = [];
    var newTypes:Map<WireType<Dynamic>, WireRegistry> = [];
    var nodes:Array<Node> = [];

    function add(key:Key, type:WireType<Dynamic>, wire:Wire<Dynamic>) {
      if (!newTypes.exists(type)) {
        newTypes.set(type, new WireRegistry());
      }
      newTypes.get(type).put(key, wire);
      newChildList.push(wire);
      nodes = nodes.concat(wire.__getNodes());
    }

    function process(nodes:Array<VNode>) for (n in nodes) switch n {
      case null:

      case VNative(type, attrs, children, key, ref): switch __resolveChildNode(type, key) {
        case null:
          var wire = type.__create(attrs, context);
          wire.__setup(this);
          wire.__update(attrs, children, context);
          add(key, type, wire);
          // todo: figure out how to handle ref
          // if (ref != null) ref(wire.__getNode());
          if (ref != null) {
            trace("Warning: Ref isn't implemented yet");
          }
        case wire:
          wire.__update(attrs, children, context);
          add(key, type, wire);
      }

      case VComponent(type, attrs, key): switch __resolveChildNode(type, key) {
        case null:
          var wire = type.__create(attrs, context);
          wire.__setup(this);
          wire.__update(attrs, [], context);
          add(key, type, wire);
        case wire:
          wire.__update(attrs, [], context);
          add(key, type, wire);
      }

      case VFragment(children):
        process(children);
    }

    process(children);

    if (__childList != null && __childList.length > 0) {
      for (wire in __childList) {
        wire.__dispose(); // Will not remove from DOM.
      }
    }

    __types = newTypes;
    __childList = newChildList;

    return nodes;
  }

  function __updateAttributes(attrs:Attrs, context:Context) {
    throw 'not implemented';
  }

  function __resolveChildNode(type:WireType<Dynamic>, ?key:Key) {
    var registry = __types.get(type);
    if (registry == null) return null;
    var n = registry.pull(key);
    __childList.remove(n);
    return n;
  }

}