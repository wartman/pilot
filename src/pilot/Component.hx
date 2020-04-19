package pilot;

// Todo: currently, the way we check `__shouldRender` is really
//       inconsitant and a bit hard to follow. Reconsider when
//       it is called.
@:autoBuild(pilot.builder.ComponentBuilder.build())
class Component implements Wire<Dynamic, Dynamic> {
  
  var __alive:Bool = false;
  var __inserted:Bool = false;
  var __dirty:Bool = false;
  var __cache:WireCache<Dynamic>;
  var __context:Context<Dynamic>;
  var __parent:Component;
  var __pendingChildren:Array<Component> = [];

  public function render():VNode {
    return null;
  }

  #if !macro
  
    macro function html(e, ?options);

    macro function css(e, ?options);
  
  #else

    static function html(_, e, ?options) {
      return pilot.Html.create(e, options);
    }

    static function css(_, e, ?options:haxe.macro.Expr) {
      return pilot.Style.create(e, options);
    }

  #end

  public function __getNodes():Array<Dynamic> {
    var nodes:Array<Dynamic> = [];
    __cache.each(node -> nodes.push(node));
    return nodes;
  }

  public function __update(
    attrs:Dynamic,
    ?_:Array<VNode>,
    context:Context<Dynamic>,
    parent:Component,
    effectQueue:Array<()->Void>
  ) {
    if (!__alive) {
      __init();
      __alive = true;
    }
    __parent = parent;
    __context = context;
    __updateAttributes(attrs);
    if (__cache == null || __shouldRender(attrs)) {
      __render(effectQueue);
    }
  }
  
  public function __destroy() {
    __alive = false;
    __pendingChildren = null;
    if (__cache != null) for (c in __cache.children) {
      c.__destroy();
    }
  }

  public function __updateAttributes(_:Dynamic) {
    throw 'assert';
  }

  function __render(effectQueue:Array<()->Void>) {
    if (!__alive) {
      throw 'Cannot render components that have been destroyed';
    }

    __dirty = false;

    __pendingChildren = [];

    var before = __cache;
    var previousCount = 0;

    if (before != null) before.each(_ -> previousCount++);
    
    __cache = __context.engine.differ.diff(
      switch render() {
        case null | VFragment([]): [ __context.engine.placeholder(this) ];
        case VFragment(children): children;
        case node: [ node ];
      },
      this,
      __context,
      effectQueue,
      (type, key) -> {
        if (before == null) return None;
        if (!before.types.exists(type)) return None;
        return switch before.types.get(type) {
          case null: None;
          case t: switch t.pull(key) {
            case null: None;
            case v: Some(v);
          }
        }
      }
    );

    if (before != null) {
      var first = before.first();
      for (t in before.types) t.each(wire -> wire.__destroy());
      if (first != null) __context.engine.differ.setChildren(
        previousCount,
        __context.engine.traverseSiblings(first),
        __cache
      );
    }
        
    effectQueue.push(this.__effect);
  }

  function __requestUpdate() {
    if (__dirty) return;

    if (__parent == null) {
      Helpers.later(() -> {
        var effectQueue:Array<()->Void> = [];
        __render(effectQueue);
        Helpers.commitComponentEffects(effectQueue);
      });
    } else {
      __dirty = true;
      __parent.__enqueuePendingChild(this);
    }
  }

  function __enqueuePendingChild(child:Component) {
    if (__pendingChildren.indexOf(child) < 0) {
      __pendingChildren.push(child);
    }
    if (__parent != null) {
      __parent.__enqueuePendingChild(this);
    } else {
      Helpers.later(() -> {
        var effectQueue:Array<()->Void> = [];
        __dequeuePendingChildren(effectQueue);
        Helpers.commitComponentEffects(effectQueue);
      });
    }
  }

  function __dequeuePendingChildren(effectQueue:Array<()->Void>) {
    if (__pendingChildren.length == 0) return;
    var children = __pendingChildren.copy();
    __pendingChildren = [];
    for (child in children) {
      if (child.__alive) {
        if (child.__dirty) {
          child.__render(effectQueue);
        } else {
          child.__dequeuePendingChildren(effectQueue);
        }
      }
    }
  }

  function __shouldRender(_:Dynamic):Bool {
    return true;
  }

  function __effect() {
    // noop
  }

  function __init() {
    if (__inserted) {
      throw 'Cannot reuse a Component that has already been inserted';
    }
    __inserted = true;
  }

}
