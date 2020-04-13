package pilot;

#if !macro

// Todo: currently, the way we check `__shouldRender` is really
//       inconsitant and a bit hard to follow. Reconsider when
//       it is called.
@:autoBuild(pilot.Component.build())
class Component implements Wire<Dynamic, Dynamic> {
  
  var __alive:Bool = false;
  var __inserted:Bool = false;
  var __dirty:Bool = false;
  var __updating:Bool = false;
  var __cache:WireCache<Dynamic>;
  var __context:Context<Dynamic>;
  var __parent:Component;
  var __pendingChildren:Array<Component> = [];

  public function render():VNode {
    return null;
  }

  macro function html(e, ?options);

  macro function css(e, ?options);

  public function __getNodes():Array<Dynamic> {
    var nodes:Array<Dynamic> = [];
    __cache.each(node -> nodes.push(node));
    return nodes;
  }

  public function __update(
    attrs:Dynamic,
    ?_:Array<VNode>,
    context:Context<Dynamic>,
    parent:Component
  ) {
    if (!__alive) {
      __init();
      __alive = true;
    }
    __parent = parent;
    __context = context;
    if (__cache == null || __shouldRender(attrs)) {
      __updateAttributes(attrs);
      __render();
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

  function __render() {
    if (!__alive) {
      throw 'Cannot render components that have been destroyed';
    }

    __dirty = false;

    __pendingChildren = [];

    var before = __cache;
    var first:Dynamic = null;
    var previousCount = 0;

    if (before != null) {
      before.each(node -> {
        if (first == null) first = node;
        previousCount++;
      });
    }

    __cache = __context.engine.differ.diff(
      switch render() {
        case null | VFragment([]): [ __context.engine.placeholder(this) ];
        case VFragment(children): children;
        case node: [ node ];
      },
      this,
      __context,
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
      for (t in before.types) t.each(wire -> wire.__destroy());
    }

    if (first != null) __context.engine.differ.setChildren(
      previousCount,
      __context.engine.traverseSiblings(first),
      __cache
    );

    // todo: this should be passed to the differ and called later
    //       in a batch AFTER all diffing is completed.
    this.__effect();
  }

  function __requestUpdate() {
    if (__dirty) return;

    if (__parent == null) {
      __updating = true;
      Helpers.later(() -> {
        __render();
        __updating = false;
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
    } else if (!__updating) {
      __updating = true;
      Helpers.later(() -> {
        __dequeuePendingChildren();
        __updating = false;
      });
    }
  }

  function __dequeuePendingChildren() {
    if (__pendingChildren.length == 0) return;
    var children = __pendingChildren.copy();
    __pendingChildren = [];
    for (child in children) {
      if (child.__alive) {
        if (child.__dirty) {
          child.__render();
        }
        child.__dequeuePendingChildren();
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

#else

import haxe.macro.Context;
import haxe.macro.Expr;
import pilot.builder.ClassBuilder;
import pilot.builder.AttributeBuilder;
import pilot.builder.HookBuilder;

class Component {

  static final ATTRS = '__attrs';
  static final INCOMING_ATTRS = '__incomingAttrs';
  static final OPTIONAL_META =  { name: ':optional', pos: (macro null).pos };

  static function html(_, e, ?options) {
    return pilot.Html.create(e, options);
  }

  static function css(_, e, ?options:haxe.macro.Expr) {
    return pilot.Style.create(e, options);
  }

  public static function build() {
    var fields = Context.getBuildFields();
    var cls = Context.getLocalClass().get();
    var clsTp:TypePath = { pack: cls.pack, name: cls.name };
    var props:Array<Field> = [];
    var updateProps:Array<Field> = [];
    var updates:Array<Expr> = [];
    var attributeUpdates:Array<Expr> = [];
    var initializers:Array<ObjectField> = [];
    var builder = new ClassBuilder(fields, cls);
    var guards:Array<Expr> = [];
    var initHooks:Array<Hook> = [];
    var effectHooks:Array<Hook> = [];
    var disposeHooks:Array<Hook> = [];

    function addProp(name:String, type:ComplexType, isOptional:Bool) {
      props.push({
        name: name,
        kind: FVar(type, null),
        access: [ APublic ],
        meta: isOptional ? [ OPTIONAL_META ] : [],
        pos: (macro null).pos
      });
      updateProps.push({
        name: name,
        kind: FVar(type, null),
        access: [ APublic ],
        meta: [ OPTIONAL_META ],
        pos: (macro null).pos
      });
      attributeUpdates.push(macro {
        if (Reflect.hasField($i{INCOMING_ATTRS}, $v{name})) switch [ $i{ATTRS}.$name, Reflect.field($i{INCOMING_ATTRS}, $v{name}) ] {
          case [ a, b ] if (a == b):
          case [ _, b ]: 
            // __changed++;
            $i{ATTRS}.$name = b;
        }
      });
    }

    // todo: we can make the AttributeBuilder nicer
    builder.addFieldBuilder(new AttributeBuilder(
      expr -> initializers.push(expr),
      addProp,
      name -> macro if (__shouldRender({ $name: value })) __requestUpdate(),
      {
        makePublic: false,
        propsName: ATTRS,
        initArg: INCOMING_ATTRS,
        updatesArg: INCOMING_ATTRS
      }
    ));
    builder.addFieldBuilder({
      name: ':update',
      similarNames: [ 'update', ':udate', ':updat' ],
      multiple: false,
      hook: After,
      options: [],
      build: (options:{}, builder, field) -> switch field.kind {
        case FFun(func):
          if (func.ret != null) {
            Context.error('@:update functions should not define their return type manually', field.pos);
          }
          var updatePropsRet = TAnonymous(updateProps);
          var e = func.expr;
          func.ret = macro:Void;
          func.expr = macro {
            inline function closure():$updatePropsRet ${e};
            var incoming = closure();
            if (__shouldRender(incoming)) {
              __updateAttributes(incoming);
              __requestUpdate();
            }
          }
        default:
          Context.error('@:update must be used on a method', field.pos);
      }
    });
    builder.addFieldBuilder({
      name: ':guard',
      similarNames: [
        'guard', ':gurad', ':gruad'
      ],
      multiple: false,
      hook: After,
      options: [],
      build: (options:{}, builder, field) -> switch field.kind {
        case FFun(func):
          var name = field.name;
          if (func.args.length == 0) {
            guards.push(macro @:pos(field.pos) this.$name());
          } else if (func.args.length == 1) {
            guards.push(macro @:pos(field.pos) this.$name($i{INCOMING_ATTRS}));
          } else {
            Context.error('`@:guard` methods must have one or no arguments', field.pos);
          }
        default:
          Context.error('@:guard must be used on a method', field.pos);
      }
    });
    builder.addFieldBuilder(new HookBuilder(
      ':init',
      [ 'init', ':initialize' ],
      hook -> initHooks.push(hook)
    ));
    builder.addFieldBuilder(new HookBuilder(
      ':effect',
      [ 'effect', ':efect', ':effct' ],
      hook -> effectHooks.push(hook)
    ));
    builder.addFieldBuilder(new HookBuilder(
      ':dispose',
      [ 'dispose', ':dispse', ':dispos' ],
      hook -> disposeHooks.push(hook)
    ));

    builder.run();

    var propType = TAnonymous(props);
    var createParams:Array<TypeParamDecl> = [
      { name: 'Node', constraints: [ macro:{} ] }
    ].concat(cls.params.length > 0
      ? [ for (p in cls.params) { name: p.name, constraints: [] } ]
      : []
    );

    builder.add([

      {
        name: '__create',
        pos: (macro null).pos,
        access: [ APublic, AStatic ],
        kind: FFun({
          params: createParams,
          // Todo: figure out how we can NOT have to use `cast` here
          expr: macro return cast new $clsTp(props, context),
          args: [
            { name: 'props', type: macro:$propType },
            { name: 'context', type: macro:pilot.Context<Node> }
          ],
          ret: macro:pilot.Wire<Node, $propType>
        })
      },
      
      {
        name: 'node',
        access: [ AStatic, APublic ],
        pos: cls.pos,
        kind: FFun({
          ret: macro:pilot.VNode,
          params: createParams,
          args: [
            { name: 'attrs', type: macro:$propType },
            { name: 'key', type: macro:Null<pilot.Key>, opt: true }
          ],
          expr: macro return pilot.VNode.VComponent(
            $p{ cls.pack.concat([ cls.name ]) },
            attrs,
            key
          )
        })
      }

    ]);

    var guardCheck = macro return true;
    if (guards.length > 0) {
      guardCheck = guards[0];
      for (i in 1...guards.length) {
        guardCheck = macro ${guardCheck} && ${guards[i]};
      }
      guardCheck = macro if (${guardCheck}) return true else return false;
    }

    function prepareHooks(hooks:Array<Hook>):Array<Expr> {
      hooks.sort((a, b) -> {
        return if (a.priority < b.priority) -1
        else if (a.priority > b.priority) 1
        else 0;
      });
      return hooks.map(h -> h.expr);
    }

    builder.add((macro class {

      var $ATTRS:$propType;

      public function new($INCOMING_ATTRS:$propType, context:pilot.Context<Dynamic>) {
        this.__context = context;
        this.$ATTRS = ${ {
          expr: EObjectDecl(initializers),
          pos: Context.currentPos()
        } };
        // todo: init stuff
      }

      override function __updateAttributes($INCOMING_ATTRS:Dynamic) {
        $b{attributeUpdates};
      }

      override function __shouldRender($INCOMING_ATTRS:Dynamic) {
        return ${guardCheck};
      }

      override function __init() {
        super.__init();
        $b{prepareHooks(initHooks)}
      }

      override function __effect() {
        $b{prepareHooks(effectHooks)}
      }

      override function __destroy() {
        $b{prepareHooks(disposeHooks)}
        super.__destroy();
      }

    }).fields);

    return builder.export();
  }

}

#end
