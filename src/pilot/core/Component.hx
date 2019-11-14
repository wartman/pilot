package pilot.core;

#if !macro

@:autoBuild(pilot.core.Component.build())
class Component<Real:{}> implements Wire<Dynamic, Real> {
  
  @:noCompletion var _pilot_type:NodeType<Dynamic, Real>;
  @:noCompletion var _pilot_wire:Wire<Dynamic, Real>;
  @:noCompletion var _pilot_parent:Wire<Dynamic, Real>;
  @:noCompletion var _pilot_context:Context;

  @:noCompletion public function _pilot_update(attrs:Dynamic, context:Context) {
    _pilot_context = context;
    if (_pilot_wire == null && componentShouldRender(attrs)) {
      _pilot_setProperties(attrs, context);
      _pilot_doInitialRender(render(), context);
    } else if (componentShouldRender(attrs)) {
      _pilot_setProperties(attrs, context);
      _pilot_doDiffRender(render(), context);
    }
  }

  @:noCompletion function _pilot_doInitialRender(rendered:VNode<Real>, context:Context) {
    switch rendered {
      case VNative(type, attrs, children, _):
        _pilot_type = type;
        _pilot_wire = type._pilot_create(attrs, context);
        _pilot_wire._pilot_updateChildren(children, context);

      case VComponent(type, attrs, _):
        _pilot_type = type;
        _pilot_wire = type._pilot_create(attrs, context);

      case VFragment(children):
        _pilot_type = WireFragment;
        _pilot_wire = new WireFragment();
        _pilot_wire._pilot_updateChildren(children, context);
    }
    context.later(_pilot_doEffects);
  }

  
  @:noCompletion function _pilot_doDiffRender(rendered:VNode<Real>, context:Context) {
    switch rendered {
      case VNative(_, attrs, children, _):
        _pilot_wire._pilot_update(attrs, context);
        _pilot_wire._pilot_updateChildren(children, context);

      case VComponent(_, attrs, _):
        _pilot_wire._pilot_update(attrs, context);

      case VFragment(children):
        _pilot_wire._pilot_updateChildren(children, context);
    }
    context.later(_pilot_doEffects);
  }

  function componentShouldRender(newAttrs:Dynamic):Bool {
    return true;
  }

  function render():VNode<Real> {
    return null;
  }

  macro function html(e);

  inline function getRealNode() {
    return _pilot_getReal();
  }

  @:noCompletion public function _pilot_getReal():Real {
    return if (_pilot_wire != null) _pilot_wire._pilot_getReal() else null;
  }

  @:noCompletion public function _pilot_insertInto(parent:Wire<Dynamic, Real>) {
    _pilot_parent = parent;
    _pilot_wire._pilot_insertInto(parent);
  }

  @:noCompletion public function _pilot_removeFrom(parent:Wire<Dynamic, Real>) {
    if (_pilot_wire != null) _pilot_wire._pilot_removeFrom(parent);
    _pilot_dispose();
  }
  
  @:noCompletion public function _pilot_appendChild(child:Wire<Dynamic, Real>) {
    if (_pilot_wire != null) _pilot_wire._pilot_appendChild(child);
  }

  @:noCompletion public function _pilot_removeChild(child:Wire<Dynamic, Real>) {
    if (_pilot_wire != null) _pilot_wire._pilot_removeChild(child);
  }

  @:noCompletion public function _pilot_updateChildren(children:Array<VNode<Real>>, context:Context) {
    _pilot_wire._pilot_updateChildren(children, context);
  }

  @:noCompletion public function _pilot_dispose() {
    if (_pilot_wire != null) {
      _pilot_wire._pilot_dispose();
    }
    _pilot_parent = null;
    _pilot_wire = null;
    _pilot_type = null;
  }

  @:noCompletion function _pilot_setProperties(attrs:Dynamic, context:Context):Dynamic {
    return {};
  }

  @:noCompletion function _pilot_doEffects() {
    // noop -- handled by macro
  }

  // // Keeping this around just in case.
  // function _pilot_doDiffRender(rendered:VNode<Real>, context:Context) {
  //   componentWillUpdate();
  //   switch rendered {
  //     case VNative(type, attrs, children, _):
  //       if (_pilot_type != type) {
  //         componentWillUnmount(_pilot_getReal());
  //         _pilot_wire._pilot_dispose();
  //         _pilot_type = type;
  //         _pilot_wire = type._pilot_create(attrs, context);
  //         context.later(() -> componentDidMount(_pilot_getReal()));
  //       } else {
  //         _pilot_wire._pilot_update(attrs, context);
  //       }

  //       _pilot_wire._pilot_updateChildren(children, context);

  //     case VComponent(type, attrs, _):
  //       if (_pilot_type != type) {
  //         componentWillUnmount(_pilot_getReal());
  //         _pilot_wire._pilot_dispose();
  //         _pilot_type = type;
  //         _pilot_wire = type._pilot_create(attrs, context);
  //         context.later(() -> componentDidMount(_pilot_getReal()));
  //       } else {
  //         _pilot_wire._pilot_update(attrs, context);
  //       }

  //     case VFragment(children):
  //       if (_pilot_type != WireFragment) {
  //         componentWillUnmount(_pilot_getReal());
  //         _pilot_wire._pilot_dispose();
  //         _pilot_type = WireFragment;
  //         _pilot_wire = new WireFragment();
  //         context.later(() -> componentDidMount(_pilot_getReal()));
  //       }
  //       _pilot_wire._pilot_updateChildren(children, context);
  //   }
  // }

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
          case macro inject = ${injectExpr}: switch injectExpr {
            case macro true:
              isOptional = true;
              e = e != null
                ? macro @:pos(f.pos) __context.get($v{name}, $e)
                : macro @:pos(f.pos) __context.get($v{name});
            case macro false: 
              // ignore
            case { expr: EConst(CString(s, _)), pos:_ }:
              isOptional = true;
              e = e != null
                ? macro @:pos(f.pos) __context.get($v{s}, $e)
                : macro @:pos(f.pos) __context.get($v{s});
            case { expr: EConst(CIdent(s)), pos:_ }:
              isOptional = true;
              e = e != null
                ? macro @:pos(f.pos) __context.get(__props.$s, $e)
                : macro @:pos(f.pos) __context.get(__props.$s);
            default:
              Context.error('Invalid argument for `inject`', param.pos);
          }
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
        newFields = newFields.concat((macro class {
          function $getName() return _pilot_props.$name;
        }).fields);

        if (isState) {
          newFields = newFields.concat((macro class {
            function $setName(value) {
              var props = Reflect.copy(_pilot_props);
              props.$name = value;
              if (_pilot_context != null) {
                _pilot_update(props, _pilot_context);
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
        effect.push(macro @:pos(f.pos) this.$name());

      default:
    }

    var propType = TAnonymous(props);

    newFields = newFields.concat((macro class {
      
      @:noCompletion var _pilot_props:$propType;

      @:noCompletion public static function _pilot_create(props, context:pilot.core.Context) {
        return new $clsTp(props, context);
      } 
      
      public function new(__props:$propType, context:pilot.core.Context) {
        _pilot_update(__props, context);
        $b{startup};
      }

      override function _pilot_setProperties(__props:Dynamic, __context:pilot.core.Context) {
        return _pilot_props = ${ {
          expr: EObjectDecl(initializers),
          pos: Context.currentPos()
        } };
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
