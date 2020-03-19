package pilot;

#if !macro

import pilot.dom.Node;

using Reflect;
using pilot.DiffingTools;

@:allow(pilot.Plugin)
@:autoBuild(pilot.Component.build())
class Component implements Wire<Dynamic> {
  
  var __attrs:Dynamic;
  var __types:Map<WireType<Dynamic>, WireRegistry> = [];
  var __childList:Array<Wire<Dynamic>> = [];
  var __context:Context;
  var __alive:Bool = false;
  var __parent:Wire<Dynamic>;
  var __initialized:Bool = false;
  var __nodes:Array<Node> = [];
  var __updating:Bool = false;
  var __pendingAttributes:{};
  final __onInit:Signal<Component> = new Signal();
  final __onEffect:Signal<Component> = new Signal();
  final __onDisposal:Signal<Component> = new Signal();

  function render():VNode {
    return null;
  }

  macro function html(e, ?options);

  macro function css(e, ?options);

  public function __requestUpdate(nextAttrs:Dynamic) {
    if (!__alive || __context == null) {
      throw 'Cannot update a component that has not been inserted';
    }

    if (__pendingAttributes == null) {
      __pendingAttributes = nextAttrs;
    } else {
      for (field in nextAttrs.fields()) {
        __pendingAttributes.setField(field, nextAttrs.field(field));
      }
    }

    if (__updating) return;

    __updating = true;
    __context.enqueueRender(() -> {
      var later = Signal.createVoidSignal();
      var cursor = __getCursor();
      var previousCount = __nodes.length;
      __update(__pendingAttributes, [], later);
      cursor.sync(__nodes, previousCount);
      __pendingAttributes = __attrs;
      __updating = false;
      later.enqueue(null);
    });
  }

  public function __setup(parent:Wire<Dynamic>, context:Context) {
    __alive = true;
    __parent = parent;
    __context = context;
  }

  public function __dispose() {
    for (c in __childList) c.__dispose();
    __childList = null;
    __alive = false;
    __parent = null;
    __types = null;
    __onDisposal.dispatch(this);
    __context = null;
  }

  public function __update(
    attrs:Dynamic,
    children:Array<VNode>,
    later:Signal<Any>
  ) {
    if (!__alive) {
      throw 'Cannot update a component that has not been inserted';
    }

    __updateAttributes(attrs);

    if (!__initialized) {
      __initialized = true;
      __onInit.dispatch(this);
    }

    if (__shouldRender(attrs)) {
      // Note: Components do not update the Dom directly unless you call
      //       `Component#__requestUpdate`.
      __nodes = this.diffChildren(__context, __getRendered(), later);
      later.addOnce(_ -> __onEffect.dispatch(this));
    }
  }
  
  function __updateAttributes(attrs:Dynamic) {
    throw 'not implemented';
  }

  function __getRendered():Array<VNode> {
    return switch render().flatten() {
      case null | VFragment([]): [ VNode.VNative(TextType, '', []) ];
      case VFragment(children): children;
      case vn: [ vn ];
    }
  }

  public function __getNodes():Array<Node> {
    return __nodes;
  }

  function __getCursor():Cursor {
    var first = __nodes[0];
    return new Cursor(first.parentNode, first);
  }

  public function __getChildList():Array<Wire<Dynamic>> {
    return __childList;
  }
  
  public function __setChildList(childList:Array<Wire<Dynamic>>):Void {
    __childList = childList;
  }

  public function __getWireTypeRegistry():Map<WireType<Dynamic>, WireRegistry> {
    return __types;
  }

  public function __setWireTypeRegistry(types:Map<WireType<Dynamic>, WireRegistry>):Void {
    __types = types;
  }

  function __shouldRender(attrs:Dynamic):Bool {
    return true;
  }

}

#else 

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using haxe.macro.ComplexTypeTools;

class Component {

  static final initMeta = [ ':init', ':initialize' ];
  static final disposeMeta = [ ':dispose' ];
  static final effectMeta = [ ':effect' ];
  static final guardMeta = [ ':guard' ];
  static final attrsMeta = [ ':attr', ':attribute' ];
  static final updateMeta = [ ':update' ];
  static final coreComponent = ':coreComponent';

  static function html(_, e, ?options) {
    return pilot.Html.create(e, options);
  }

  static function css(_, e, ?options:haxe.macro.Expr) {
    return pilot.Style.create(e, options);
  }

  // Todo: this build function should be refactored and cleaned up.
  public static function build() {
    var cls = Context.getLocalClass().get();
    var clsTp:TypePath = { pack: cls.pack, name: cls.name };
    var fields = Context.getBuildFields();
    var newFields:Array<Field> = [];
    var props:Array<Field> = [];
    var updateProps:Array<Field> = [];
    var startup:Array<Expr> = [];
    var dispose:Array<Expr> = [];
    var effect:Array<Expr> = [];
    var guards:Array<Expr> = [];
    var attributeUpdates:Array<Expr> = [];
    var initializers:Array<ObjectField> = [];

    function add(fields:Array<Field>) {
      newFields = newFields.concat(fields);
    }

    // Don't implement core components: these are designed
    // to provide extra functionality.
    if (cls.meta.has(coreComponent)) {
      return fields;
    }
    
    for (f in fields) switch (f.kind) {
      case FVar(t, e) if (f.meta.exists(m -> attrsMeta.has(m.name))):

        if (f.meta.filter(m -> attrsMeta.has(m.name)).length > 1) {
          Context.error('More than one `@:attribute` is not allowed per var', f.pos);
        }

        var name = f.name;
        var isOptional = e != null || f.meta.exists(m -> m.name == ':optional');
        var params = f.meta.find(m -> attrsMeta.has(m.name)).params;
        var getName = 'get_${name}';
        var setName = 'set_${name}';
        var isState = false;
        var guardName = '__guard_${name}';
        var guard:Expr = macro __a != __b;

        for (param in params) switch param {
          case macro state: isState = true;
          case macro state = ${e}: switch e {
            case macro false: isState = false;
            case macro true: isState = true;
            default: 
              Context.error('Attribute option `state` must be Bool', param.pos);
          }
          case macro inject = ${injectExpr}:
            isOptional = true;
            e = e != null
              ? macro @:pos(f.pos) __context.get(${injectExpr}, $e)
              : macro @:pos(f.pos) __context.get(${injectExpr});
          case macro optional: isOptional = true;
          case macro guard = ${e}:
            guard = macro @:pos(e.pos) ${guard} && ${e}(__a, __b);
          case macro optional = ${e}: switch e {
            case macro true: isOptional = true;
            case macro false: isOptional = false;
            default:
              Context.error('Attribute option `optional` must be Bool', param.pos);
          }
          default:
            Context.error('Invalid attribute option', param.pos);
        }
        
        f.kind = isState 
          ? FProp('get', 'set', t, null)
          : FProp('get', 'never', t, null);

        if (e != null) {
          initializers.push({
            field: name,
            expr: macro __props.$name != null ? __props.$name : $e
          });
        } else {
          initializers.push({
            field: name,
            expr: macro __props.$name
          });
        }

        updateProps.push({
          name: name,
          kind: FVar(t, null),
          access: [ APublic ],
          meta: [ { name: ':optional', pos: f.pos } ],
          pos: (macro null).pos
        });

        // TODO:
        // Guards should happen in `__update` for all attributes, and we should ONLY render if 
        // attributes change?

        attributeUpdates.push(macro @:pos(f.pos) {
          if (Reflect.hasField(__props, $v{name})) switch [ __attrs.$name, Reflect.field(__props, $v{name}) ] {
            case [ a, b ] if (!this.$guardName(a, b)):
            case [ _, b ]: __attrs.$name = b;
          }
        });

        add((macro class {

          function $getName() return __attrs.$name;
          
          inline function $guardName(__a, __b) return ${guard};

        }).fields);

        if (isState) {
          add((macro class {
            function $setName(__v) {
              if (this.$guardName(__v, __attrs.$name)) __requestUpdate({ $name: __v });
              return __v;
            }
          }).fields);
        }

        props.push({
          name: name,
          kind: FVar(t, null),
          access: [ APublic ],
          meta: isOptional ? [ { name: ':optional', pos: f.pos } ] : [],
          pos: f.pos
        });
      
      case FFun(_) if (f.meta.exists(m -> initMeta.has(m.name))):
        var name = f.name;
        startup.push(macro @:pos(f.pos) this.$name());

      case FFun(_) if (f.meta.exists(m -> disposeMeta.has(m.name))):
        var name = f.name;
        dispose.push(macro @:pos(f.pos) this.$name());

      case FFun(_) if (f.meta.exists(m -> effectMeta.has(m.name))):
        var name = f.name;
        var params = f.meta.find(m -> effectMeta.has(m.name)).params;
        var guarded:Expr;

        for (p in params) switch p {
          case macro guard = ${e}:
            guarded = macro @:pos(p.pos) if (${e}) this.$name();
          default: 
            Context.error('Invalid effect option', p.pos);
        }

        if (guarded != null) 
          effect.push(guarded) 
        else 
          effect.push(macro @:pos(f.pos) this.$name());

      case FFun(func) if (f.meta.exists(m -> guardMeta.has(m.name))):
        var name = f.name;
        var params = f.meta.find(m -> guardMeta.has(m.name)).params;
        var check:Expr;

        if (params.length != 0) {
          Context.error('`@:guard` does not have any options', f.pos);
        }

        if (func.args.length == 0) {
          guards.push(macro @:pos(f.pos) this.$name());
        } else if (func.args.length == 1) {
          guards.push(macro @:pos(f.pos) this.$name(attrs));
        } else {
          Context.error('`@:guard` methods must have one or no arguments', f.pos);
        }

      default:
    }

    var updateRet = TAnonymous(updateProps);

    for (f in fields) switch f.kind {

      case FFun(func) if (f.meta.exists(m -> updateMeta.has(m.name))):
        if (func.ret != null) {
          Context.error('`@:update` functions should not define their return type manually', f.pos);
        }
        var e = func.expr;
        func.ret = macro:Void;
        func.expr = macro {
          var closure:()->$updateRet = () -> ${e};
          __requestUpdate(closure());
        }

      default: // noop

    }

    var propType = TAnonymous(props);
    var guardCheck = macro return true;
    if (guards.length > 0) {
      guardCheck = guards[0];
      for (i in 1...guards.length) {
        guardCheck = macro ${guardCheck} && ${guards[i]};
      }
      guardCheck = macro if (${guardCheck}) return true else return false;
    }
    var initInits = startup.length > 0
      ? macro __onInit.add(_ -> { $b{startup}; })
      : macro null;
    var initEffects = effect.length > 0
      ? macro __onEffect.add(_ -> { $b{effect}; })
      : macro null;
      
    // Note: We do this somewhat inelegant thing here as we need
    // to give the `__create` function any type params the Component
    // might expect. There might be a better way of doing this!
    add([ {
      name: '__create',
      pos: (macro null).pos,
      access: [ APublic, AStatic ],
      kind: FFun({
        params: cls.params.length > 0
          ? [ for (p in cls.params) { name: p.name } ]
          : [],
        expr: macro return new $clsTp(props, context),
        args: [
          { name: 'props', type: macro:$propType },
          { name: 'context', type: macro:pilot.Context }
        ],
        ret: null
      })
    } ]);

    add((macro class {
      
      public function new(__props:$propType, __context:pilot.Context) {
        this.__context = __context;
        __attrs = ${ {
          expr: EObjectDecl(initializers),
          pos: Context.currentPos()
        } };
        ${initInits};
        ${initEffects};
      }

      override function __updateAttributes(__props:Dynamic) {
        $b{attributeUpdates};
      }

      override function __shouldRender(attrs:Dynamic) {
        ${guardCheck}
      }

      override function __dispose() {
        $b{dispose};
        super.__dispose();
      }

    }).fields);
    
    return fields.concat(newFields);
  }

}

#end
