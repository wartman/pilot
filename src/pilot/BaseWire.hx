package pilot;

import pilot.dom.*;

class BaseWire<Attrs:{}> implements Wire<Attrs> {

  var __attrs:Attrs;
  var __types:Map<WireType<Dynamic>, WireRegistry> = [];
  var __childList:Array<Wire<Dynamic>> = [];
  var __context:Context;
  
  public function __getNodes():Array<Node> {
    throw 'not implemented';
  }

  public function __setup(parent:Wire<Dynamic>, context:Context):Void {
    __context = context;
  }

  public function __update(
    attrs:Attrs,
    children:Array<VNode>,
    later:Later
  ) {
    throw 'Not implemented';
  }

  public function __dispose() {
    __context = null;
  }

  public function __getCursor():Cursor {
    throw 'not implemented';
  }

  function __setChildren(nextNodes:Array<Node>, cursor:Cursor, previousCount:Int) {
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
    later:Later
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

    // todo: clear up these errors in the parser?
    function updateNative(
      wire:Wire<Dynamic>, 
      innerHTML:Null<String>,
      attrs:Dynamic,
      children:Array<VNode>,
      later:Later
    ) {
      wire.__update(attrs, children, later);
      if (innerHTML != null) {
        if (children.length > 0) {
          throw 'Do not use @dangerouslySetInnerHTML with child VNodes';
        }
        switch wire.__getNodes() {
          case [ node ]: switch Std.downcast(node, Element) {
            case null: throw '@dangerouslySetInnerHTML must be used with a valid element';
            case el: el.innerHTML = innerHTML;
          }
          default: throw 'assert';
        }
      }
    }

    function process(nodes:Array<VNode>) for (n in nodes) switch n {
      case null:

      case VNative(type, attrs, children, key, dangerouslySetInnerHTML, ref): switch __resolveChildNode(type, key) {
        case null:
          var wire = type.__create(attrs, __context);
          wire.__setup(this, __context);
          updateNative(wire, dangerouslySetInnerHTML, attrs, children, later);
          add(key, type, wire);
          if (ref != null) later.add(() -> ref(switch wire.__getNodes() {
            case [ node ]: node;
            default: throw 'assert';
          }));
        case wire:
          updateNative(wire, dangerouslySetInnerHTML, attrs, children, later);
          add(key, type, wire);
      }

      case VComponent(type, attrs, key): switch __resolveChildNode(type, key) {
        case null:
          var wire = type.__create(attrs, __context);
          wire.__setup(this, __context);
          wire.__update(attrs, [], later);
          add(key, type, wire);
        case wire:
          wire.__update(attrs, [], later);
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

  function __updateAttributes(attrs:Attrs) {
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