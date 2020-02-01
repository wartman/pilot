package pilot;

#if !macro

@:autoBuild(pilot.Component.build())
class Component extends BaseWire<Dynamic> {
  
  @:noCompletion var __parent:Wire<Dynamic>;
  @:noCompletion var __context:Context;
  @:noCompletion var __initialized:Bool = false;

  function render():VNode {
    return null;
  }

  macro function html(e);

  @:noCompletion override function __update(attrs:Dynamic, children:Array<VNode>, context:Context) {
    __context = context;
    __updateAttributes(attrs, context);

    if (!__initialized) {
      __initialized = true;
      __doInits();
    }

    if (__shouldRender(attrs)) {
      __updateChildren(switch render() {
        case null: [ VNative(TextType, '', []) ]; // placeholder?
        case VFragment(children): children;
        case vn: [ vn ];
      }, __context);
      Util.later(__doEffects);
    }
  }

  @:noCompletion function __shouldRender(attrs:Dynamic):Bool {
    return true;
  }

  @:noCompletion override function __insertInto(parent:Wire<Dynamic>) {
    __parent = parent;
    __real = parent.__getReal();
  }

  @:noCompletion override function __removeFrom(parent:Wire<Dynamic>) {
    for (c in __childList) c.__removeFrom(parent);
    __dispose();
  }

  @:noCompletion override function __dispose() {
    __parent = null;
    __types = null;
    __childList = null;
  }

  @:noCompletion function __doInits() {
    // noop -- handled by macro
  }

  @:noCompletion function __doEffects() {
    // noop -- handled by macro
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
  static final styleMeta = [ ':style' ];
  static final coreComponent = ':coreComponent';

  static function html(_, e) {
    return pilot.dsl.Markup.parse(e);
  }

  public static function build() {
    var cls = Context.getLocalClass().get();
    var clsTp:TypePath = { pack: cls.pack, name: cls.name };
    var fields = Context.getBuildFields();
    var newFields:Array<Field> = [];
    var props:Array<Field> = [];
    var startup:Array<Expr> = [];
    var dispose:Array<Expr> = [];
    var effect:Array<Expr> = [];
    var guards:Array<Expr> = [];
    var updates:Array<Expr> = [];
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
        var isMutable = false;
        var guardName = '__guard_${name}';
        var guard:Expr = macro __a != __b;

        for (param in params) switch param {
          case macro mutable: isMutable = true;
          case macro mutable = ${e}: switch e {
            case macro false: isMutable = false;
            case macro true: isMutable = true;
            default: 
              Context.error('Attribute option `mutable` must be Bool', param.pos);
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
        
        f.kind = isMutable 
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
        
        // TODO:
        // Guards should happen in `__update` for all attributes, and we should ONLY render if 
        // attributes change?

        updates.push(macro @:pos(f.pos) {
          if (Reflect.hasField(__props, $v{name})) switch [ __attrs.$name, Reflect.field(__props, $v{name}) ] {
            case [ a, b ] if (!this.$guardName(a, b)):
            case [ _, b ]: __attrs.$name = b;
          }
        });

        add((macro class {

          function $getName() return __attrs.$name;
          
          inline function $guardName(__a, __b) return ${guard};

        }).fields);

        if (isMutable) {
          add((macro class {
            function $setName(__v) {
              if (__context != null && this.$guardName(__v, __attrs.$name)) {
                __update({ $name: __v }, [], __context);
              }
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

      case FVar(t, e) if (f.meta.exists(m -> styleMeta.has(m.name))):
        
        if (f.meta.filter(m -> styleMeta.has(m.name)).length > 1) {
          Context.error('More than one `@:style` is not allowed per var', f.pos);
        }

        if (e == null) {
          Context.error('An expression is required for @:style', f.pos);
        }

        var forceEmbedding = false;
        var isGlobal = false;
        var params = f.meta.find(m -> styleMeta.has(m.name)).params;

        for (param in params) switch param {
          case macro embed: forceEmbedding = true;
          case macro embed = ${e}: switch e {
            case macro true: forceEmbedding = true;
            case macro false:
            default:
              Context.error('Bool expected', param.pos);
          }
          case macro global: isGlobal = true;
          case macro global = ${e}: switch e {
            case macro true: isGlobal = true;
            case macro false:
            default:
              Context.error('Bool expected', param.pos);
          }
          default:
            Context.error('Invalid attribute option', param.pos);
        }

        f.kind = FVar(macro:pilot.Style, pilot.dsl.Css.parse(e, forceEmbedding, isGlobal));
        if (isGlobal) {
          f.meta.push({
            name: '@:keep',
            params: [],
            pos: f.pos
          });
        }
      
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

    var propType = TAnonymous(props);
    var guardCheck = macro return true;
    if (guards.length > 0) {
      guardCheck = guards[0];
      for (i in 1...guards.length) {
        guardCheck = macro ${guardCheck} && ${guards[i]};
      }
      guardCheck = macro if (${guardCheck}) return true else return false;
    }

    add((macro class {

      @:noCompletion public static function __create(props:$propType, context:pilot.Context) {
        return new $clsTp(props, context);
      } 
      
      public function new(__props:$propType, __context:pilot.Context) {
        this.__context = __context;
        __attrs = ${ {
          expr: EObjectDecl(initializers),
          pos: Context.currentPos()
        } };
      }

      @:noCompletion override function __updateAttributes(__props:Dynamic, __context:pilot.Context) {
        $b{updates};
      }

      @:noCompletion override function __shouldRender(attrs:Dynamic) {
        ${guardCheck}
      }

      @:noCompletion override function __doInits() {
        $b{startup};
      }

      @:noCompletion override function __doEffects() {
        $b{effect};
      }

      @:noCompletion override function __dispose() {
        $b{dispose};
        super.__dispose();
      }

    }).fields);
    
    return fields.concat(newFields);
  }

}

#end
