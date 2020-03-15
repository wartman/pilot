package pilot;

import haxe.DynamicAccess;
import pilot.dom.*;

class DiffingTools {
  
  static final EMPTY = {};
  
  public static function diffObject(
    oldProps:DynamicAccess<Dynamic>,
    newProps:DynamicAccess<Dynamic>,
    apply:(key:String, oldValue:Dynamic, newValue:Dynamic)->Void
  ) {
    if (oldProps == newProps) return;

    var keys = (if (newProps == null) {
      newProps = EMPTY;
      oldProps;
    } else if (oldProps == null) {
      oldProps = EMPTY;
      newProps;
    } else {
      var ret = newProps.copy();
      for (key in oldProps.keys()) ret[key] = true;
      ret;
    }).keys();

    for (key in keys) switch [ oldProps[key], newProps[key] ] {
      case [ a, b ] if (a == b):
      case [ a, b ]: apply(key, a, b);
    } 
  }

  public static function diffChildren(
    parent:Wire<Dynamic>,
    context:Context,
    children:Array<VNode>,
    later:Signal<Any>
  ):Array<Node> {
    var newChildList:Array<Wire<Dynamic>> = [];
    var newTypes:Map<WireType<Dynamic>, WireRegistry> = [];
    var nodes:Array<Node> = [];
    var resolve = resolveChildNode.bind(parent);

    function add(key:Key, type:WireType<Dynamic>, wire:Wire<Dynamic>) {
      if (!newTypes.exists(type)) {
        newTypes.set(type, new WireRegistry());
      }
      newTypes.get(type).put(key, wire);
      newChildList.push(wire);
      nodes = nodes.concat(wire.__getNodes());
    }

    function updateNative(
      wire:Wire<Dynamic>, 
      innerHTML:Null<String>,
      attrs:Dynamic,
      children:Array<VNode>,
      later:Signal<Any>
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

      case VNative(type, attrs, children, key, innerHTML, ref): switch resolve(type, key) {
        case null:
          var wire = type.__create(attrs, context);
          wire.__setup(parent, context);
          updateNative(wire, innerHTML, attrs, children, later);
          add(key, type, wire);
          if (ref != null) later.addOnce(_ -> ref(switch wire.__getNodes() {
            case [ node ]: node;
            default: throw 'assert';
          }));
        case wire:
          updateNative(wire, innerHTML, attrs, children, later);
          add(key, type, wire);
      }

      case VComponent(type, attrs, key): switch resolve(type, key) {
        case null:
          var wire = type.__create(attrs, context);
          wire.__setup(parent, context);
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

    var childList = parent.__getChildList();

    if (childList != null && childList.length > 0) {
      for (wire in childList) {
        wire.__dispose(); // Will not remove from DOM.
      }
    }

    parent.__setWireTypeRegistry(newTypes);
    parent.__setChildList(newChildList);

    return nodes;
  }

  public static function flatten(vnode:VNode) {
    return switch vnode {
      case null: null;
      case VFragment([]): null;
      case VFragment(children):
        var c = children.map(flatten).filter(vn -> vn != null);
        if (c.length == 0) null else VNode.VFragment(c);
      case vn: vn; 
    }
  }

  static function resolveChildNode(
    target:Wire<Dynamic>,
    type:WireType<Dynamic>,
    key:Key
  ) {
    var registry = target.__getWireTypeRegistry().get(type);
    if (registry == null) return null;
    var n = registry.pull(key);
    target.__getChildList().remove(n);
    return n;
  }

}
