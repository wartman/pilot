package pilot;

#if !macro

@:autoBuild(pilot.Component.build())
class Component extends BaseWire<Dynamic> {
  
  @:noCompletion var _pilot_parent:Wire<Dynamic>;
  @:noCompletion var _pilot_context:Context;
  @:noCompletion var _pilot_later:()->Void;

  function render():VNode {
    return null;
  }

  macro function html(e);

  override function _pilot_update(attrs:Dynamic, children:Array<VNode>, context:Context) {
    _pilot_context = context;
    _pilot_updateAttributes(attrs, context);

    var getChildren = () -> switch render() {
      case VFragment(children): children;
      case vn: [ vn ];
    }

    if (_pilot_shouldRender(attrs)) {
      if (_pilot_real == null) {
        _pilot_later = () -> {
          _pilot_updateChildren(getChildren(), _pilot_context);
          Util.later(_pilot_doEffects);
        }
      } else {
        _pilot_updateChildren(getChildren(), _pilot_context);
        Util.later(_pilot_doEffects);
      }
    }
  }

  function _pilot_shouldRender(attrs:Dynamic):Bool {
    return true;
  }

  override function _pilot_insertInto(parent:Wire<Dynamic>) {
    _pilot_parent = parent;
    _pilot_real = parent._pilot_getReal();
    if (_pilot_later != null) {
      _pilot_later();
      _pilot_later = null;
    }
  }

  override function _pilot_removeFrom(parent:Wire<Dynamic>) {
    for (c in _pilot_childList) c._pilot_removeFrom(parent);
    _pilot_dispose();
  }

  override function _pilot_dispose() {
    _pilot_parent = null;
    _pilot_types = null;
    _pilot_childList = null;
  }

  @:noCompletion function _pilot_doInits() {
    // noop -- handled by macro
  }

  @:noCompletion function _pilot_doEffects() {
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
  // // Todo: rethinking how guards should work.
  // static final guardMeta = [ ':guard' ];
  static final attrsMeta = [ ':attr', ':attribute' ];
  static final styleMeta = [ ':style' ];
  static final coreComponent = ':coreComponent';

  static function html(_, e) {
    return pilot.dsl.Markup.parse(e);
  }

  public static function build() {
    var cls = Context.getLocalClass().get();
    var clsTp:TypePath = {
      pack: cls.pack,
      name: cls.name
    };
    var fields = Context.getBuildFields();
    var newFields:Array<Field> = [];
    var props:Array<Field> = [];
    var startup:Array<Expr> = [];
    var teardown:Array<Expr> = [];
    var effect:Array<Expr> = [];
    // var guards:Array<Expr> = [];
    var updates:Array<Expr> = [];
    var initializers:Array<ObjectField> = [];

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

        for (param in params) switch param {
          case macro mutable = ${e}: switch e {
            case macro false: isState = false;
            case macro true: isState = true;
            default: 
              Context.error('Attribute option `mutable` must be Bool', param.pos);
          }
          case macro inject = ${injectExpr}:
            isOptional = true;
            e = e != null
              ? macro @:pos(f.pos) __context.get(${injectExpr}, $e)
              : macro @:pos(f.pos) __context.get(${injectExpr});
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
        
        updates.push(macro @:pos(f.pos) {
          if (Reflect.hasField(__props, $v{name})) switch [ _pilot_props.$name, Reflect.field(__props, $v{name}) ] {
            case [ a, b ] if (a == b):
            case [ _, b ]: _pilot_props.$name = b;
          }
        });

        newFields = newFields.concat((macro class {
          function $getName() return _pilot_props.$name;
        }).fields);

        if (isState) {
          newFields = newFields.concat((macro class {
            function $setName(value) {
              if (_pilot_context != null) {
                _pilot_update({ $name: value }, [], _pilot_context);
              }
              return value;
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
          case macro embed = ${e}: switch e {
            case macro true: forceEmbedding = true;
            default:
          }
          case macro global = ${e}: switch e {
            case macro true: isGlobal = true;
            default:
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
        teardown.push(macro @:pos(f.pos) this.$name());

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

      // case FFun(_) if (f.meta.exists(m -> guardMeta.has(m.name))):
      //   var name = f.name;
      //   var params = f.meta.find(m -> guardMeta.has(m.name)).params;
      //   var check:Expr;

      //   for (param in params) switch param {
      //     case macro $i{field}:
      //       if (check != null) {
      //         Context.error('Only one field may be guarded for re-renders', param.pos);
      //       }
      //       var clsField = fields.find(f -> f.name == field);
      //       if (clsField == null) {
      //         Context.error('The field ${field} does not exist on this class', param.pos);
      //       }
      //       if (!clsField.meta.exists(m -> attrsMeta.has(m.name))) {
      //         Context.error('Only fields marked with @:attribute may be checked for render guards', param.pos);
      //       }
      //       var fName = clsField.name;
      //       check = macro @:pos(param.pos) !this.$name(Reflect.field(attrs, $v{clsField.name}));
      //     default:
      //       Context.error('Invalid guard option', param.pos);
      //   }

      //   guards.push(
      //     check != null
      //       ? check
      //       : macro @:pos(f.pos)!this.$name(attrs)
      //   );

      default:
    }

    var propType = TAnonymous(props);
    // var guardCheck = macro null;
    // if (guards.length > 0) {
    //   guardCheck = guards[0];
    //   for (i in 1...guards.length) {
    //     guardCheck = macro ${guardCheck} && ${guards[i]};
    //   }
    //   guardCheck = macro if (${guardCheck}) return false;
    // }

    newFields = newFields.concat((macro class {
      
      @:noCompletion var _pilot_props:$propType;

      @:noCompletion public static function _pilot_create(props:$propType, context:pilot.Context) {
        return new $clsTp(props, context);
      } 
      
      public function new(__props:$propType, __context:pilot.Context) {
        _pilot_context = __context;
        _pilot_props = ${ {
          expr: EObjectDecl(initializers),
          pos: Context.currentPos()
        } };
      }

      override function _pilot_updateAttributes(__props:Dynamic, __context:pilot.Context) {
        $b{updates};
      }

      // override function _pilot_shouldRender(attrs:Dynamic) {
      //   ${guardCheck}
      //   return true;
      // }

      override function _pilot_doInits() {
        $b{startup};
      }

      override function _pilot_doEffects() {
        $b{effect};
      }

      override function _pilot_dispose() {
        $b{teardown};
        super._pilot_dispose();
      }

    }).fields);
    
    return fields.concat(newFields);
  }

}

#end
