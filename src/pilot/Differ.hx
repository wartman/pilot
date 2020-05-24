package pilot;

import haxe.DynamicAccess;
import haxe.ds.Option;

class Differ<Node> {
  
  static final EMPTY = {};

  public final engine:Engine<Node>;

  public function new(engine) {
    this.engine = engine;
  }

  public function diff(
    nodes:Array<VNode>,
    parent:Component,
    context:Context<Node>,
    effectQueue:Array<()->Void>,
    previous:(type:WireType<Dynamic>, key:Null<Key>)->Option<Wire<Node, Dynamic>>
  ):WireCache<Node> {
    var newCache:WireCache<Node> = {
      types: [],
      children: []
    };

    function process(nodes:Array<VNode>) {
      if (nodes != null) for (n in nodes) if (n != null) {
        
        inline function add(key:Null<Key>, type:WireType<Dynamic>, wire:Wire<Node, Dynamic>) {
          if (!newCache.types.exists(type)) {
            newCache.types.set(type, new WireRegistry());
          }
          newCache.types.get(type).put(key, wire);
          newCache.children.push(wire);
        }

        // @todo: the `ref` signature is bad. We should not have to use `Any`.
        inline function handleSpecial(wire:Wire<Node, Dynamic>, ref:(node:Any)->Void, innerHtml:String) {
          switch wire.__getNodes() {
            case [ node ]:
              if (ref != null) effectQueue.push(() -> ref(node));
              if (innerHtml != null) context.engine.dangerouslySetInnerHtml(node, innerHtml);
            default: // noop
          }
        }

        switch n {
          case VNative(type, attrs, children, key, ref, dangerouslySetInnerHtml): switch previous(type, key) {
            case None:
              var wire = type.__create(attrs, context);
              wire.__update(attrs, children, context, parent, effectQueue);
              handleSpecial(wire, ref, dangerouslySetInnerHtml);
              add(key, type, wire);
            case Some(wire):
              wire.__update(attrs, children, context, parent, effectQueue);
              handleSpecial(wire, null, dangerouslySetInnerHtml);
              add(key, type, wire);
          }
          case VComponent(type, attrs, key): switch previous(type, key) {
            case None:
              var wire = type.__create(attrs, context);
              wire.__update(attrs, context, parent, effectQueue);
              add(key, type, wire);
            case Some(wire):
              wire.__update(attrs, context, parent, effectQueue);
              add(key, type, wire);
          }
          case VFragment(children):
            process(children);
        }

      }
    }

    process(nodes);
    return newCache;
  }

  public function hydrate(
    cursor:Cursor<Node>,
    nodes:Array<VNode>,
    parent:Component,
    context:Context<Node>,
    effectQueue:Array<()->Void>
  ):WireCache<Node> {
    var cache:WireCache<Node> = {
      types: [],
      children: []
    };

    inline function add(type:WireType<Dynamic>, wire:Wire<Node, Dynamic>, ?key:Key) {
      if (!cache.types.exists(type)) {
        cache.types.set(type, new WireRegistry());
      }
      cache.types.get(type).put(key, wire);
      cache.children.push(wire);
    }

    function process(nodes:Array<VNode>) {
      if (nodes != null) for (n in nodes) if (n != null) {
        switch n {
          case VNative(type, attrs, children, key, ref, dangerouslySetInnerHtml, isPlaceholder):
            var current = cursor.current();
            if (current == null || isPlaceholder) {
              // Note: this assumes that placeholders are *not* real nodes
              //       when we're hydrating. This seems reasonable enough,
              //       but it might be a bad idea to rely on it.
              var wire = type.__create(attrs, context);
              switch wire.__getNodes() {
                case [ node ]: cursor.insert(node);
                default: throw 'assert';
              }
              wire.__update(attrs, children, context, parent, effectQueue);
              add(type, wire, key);
            } else {
              var wire = type.__hydrate(current, attrs, context);
              if (dangerouslySetInnerHtml == null) {
                var c = context.engine.traverseChildren(current);
                wire.__hydrate(c, attrs, children, parent, context, effectQueue);
              }
              cursor.step();
              add(type, wire, key);
            }
            if (ref != null) effectQueue.push(() -> ref(current));

          case VComponent(type, attrs, key):
            var wire = type.__create(attrs, context);
            wire.__hydrate(cursor, attrs, parent, context, effectQueue);
            add(type, wire, key);

          case VFragment(children):
            process(children);
        }
      }
    }
    
    process(nodes);
    
    return cache;
  }

  public function setChildren(
    previousCount:Int,
    cursor:Cursor<Node>,
    next:WireCache<Node>
  ) {
    var insertedCount = 0;
    var currentCount = 0;
    for (wire in next.children) for (node in wire.__getNodes()) {
      currentCount++;
      if (node == cursor.current()) cursor.step();
      else if (cursor.insert(node)) insertedCount++;
    }
    var deleteCount = previousCount + insertedCount - currentCount;
    for (i in 0...deleteCount) {
      if (!cursor.delete()) break;
    }
  }

  public function diffObject(
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

}
