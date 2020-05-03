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
  var __lastNodes:Array<Dynamic>;
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
    if (__lastNodes == null) {
      var nodes:Array<Dynamic> = [];
      for (wire in __cache.children) {
        nodes = nodes.concat(wire.__getNodes());
      }
      __lastNodes = nodes;
    }
    return __lastNodes;
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

  public function __hydrate(
    cursor:Cursor<Dynamic>,
    attrs:Dynamic,
    ?children:Array<VNode>,
    parent:Component,
    context:Context<Dynamic>,
    effectQueue:Array<()->Void>
  ) {
    if (!__alive) {
      __init();
      __alive = true;
    }
    __parent = parent;
    __context = context;
    __updateAttributes(attrs);
    __reset(); // Just in case
    __cache = __context.engine.differ.hydrate(
      cursor,
      __processRender(),
      this,
      __context,
      effectQueue
    );
    effectQueue.push(this.__effect);
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
    var before = __cache;

    __assertAlive();
    __reset();

    __cache = __context.engine.differ.diff(
      __processRender(),
      this,
      __context,
      effectQueue,
      Helpers.createPreviousResolver(before)
    );

    if (before != null) {
      var previousCount = 0;
      var first = null;
      for (wire in before.children) for (node in wire.__getNodes()) {
        if (first == null) first = node;
        previousCount++;
      }
      for (t in before.types) t.each(wire -> wire.__destroy());
      if (first != null) __context.engine.differ.setChildren(
        previousCount,
        __context.engine.traverseSiblings(first),
        __cache
      );
    }
    
    effectQueue.push(this.__effect);
  }

  inline function __processRender() {
    return switch render() {
      case null | VFragment([]): [ __context.engine.placeholder(this) ];
      case VFragment(children): children;
      case node: [ node ];
    }
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
    
    __assertAlive();
    __reset();

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

  inline function __assertAlive() {
    if (!__alive) {
      throw 'Cannot render components that have been destroyed';
    }
  }

  inline function __reset() {
    __dirty = false;
    __pendingChildren = [];
    __lastNodes = null;
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
