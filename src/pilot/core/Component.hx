package pilot.core;

#if !macro

@:autoBuild(pilot.core.Component.build())
class Component<Real:{}> implements Wire<Dynamic, Real> {
  
  var _pilot_type:NodeType<Dynamic, Real>;
  var _pilot_wire:Wire<Dynamic, Real>;

  public function _pilot_update(attrs:Dynamic) {
    if (_pilot_wire == null && componentShouldRender(attrs)) {
      _pilot_setProperties(attrs);
      componentWillMount();

      switch render() {

        case VNative(type, attrs, children, _):
          _pilot_type = type;
          _pilot_wire = type._pilot_create(attrs);
          _pilot_wire._pilot_updateChildren(children);

        case VComponent(type, attrs, _):
          _pilot_type = type;
          _pilot_wire = type._pilot_create(attrs);

        case VFragment(_):
          throw 'Fragment is not a valid root node';
      }
      
      componentDidMount(_pilot_getReal());
    } else if (componentShouldRender(attrs)) {
      _pilot_setProperties(attrs);
      componentWillUpdate();

      switch render() {

        case VNative(type, attrs, children, _):
          var didMount:Bool = false;

          if (_pilot_type != type) {
            componentWillUnmount(_pilot_getReal());
            didMount = true;
            _pilot_wire._pilot_dispose();
            _pilot_type = type;
            _pilot_wire = type._pilot_create(attrs);
          } else {
            _pilot_wire._pilot_update(attrs);
          }

          _pilot_wire._pilot_updateChildren(children);
          if (didMount) componentDidMount(_pilot_getReal());

        case VComponent(type, attrs, _):
          if (_pilot_type != type) {
            componentWillUnmount(_pilot_getReal());
            _pilot_wire._pilot_dispose();
            _pilot_type = type;
            _pilot_wire = type._pilot_create(attrs);
            componentDidMount(_pilot_getReal());
          } else {
            _pilot_wire._pilot_update(attrs);
          }

        case VFragment(_):
          throw 'Fragment is not a valid root node';

      }
    }
  }

  public function _pilot_getReal():Real {
    return _pilot_wire._pilot_getReal();
  }
  
  public function _pilot_appendChild(child:Wire<Dynamic, Real>) {
    if (_pilot_wire != null) _pilot_wire._pilot_appendChild(child);
  }

  public function _pilot_removeChild(child:Wire<Dynamic, Real>) {
    if (_pilot_wire != null) _pilot_wire._pilot_removeChild(child);
  }

  public function _pilot_updateChildren(children:Array<VNode<Real>>) {
    throw 'Components cannot update children -- only use _pilot_update(...).';
  }

  public function _pilot_dispose() {
    componentWillUnmount(_pilot_getReal());
    if (_pilot_wire != null) _pilot_wire._pilot_dispose();
    _pilot_wire = null;
    _pilot_type = null;
  }

  function _pilot_setProperties(attrs:Dynamic) {
    // noop
  }

  function componentWillMount() {
    // noop
  }

  function componentDidMount(el:Real) {
    // noop
  }

  function componentWillUpdate() {
    // noop    
  }

  function componentWillUnmount(el:Real) {
    // noop
  }

  function componentShouldRender(newAttrs:Dynamic):Bool {
    return true;
  }

  function render():VNode<Real> {
    return null;
  }

  macro function html(e);

}

#else 

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using haxe.macro.ComplexTypeTools;

class Component {

  static final initMeta = [ ':init' ];
  static final attrsMeta = [ ':attr', ':attribute' ];
  static final styleMeta = [ ':style' ];

  // this is weird
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
    var initializers:Array<ObjectField> = [];
    
    for (f in fields) switch (f.kind) {
      case FVar(t, e) if (f.meta.exists(m -> attrsMeta.has(m.name))):

        if (f.meta.filter(m -> attrsMeta.has(m.name)).length > 1) {
          Context.error('More than one `@:attribute` is not allowed per var', f.pos);
        }

        var name = f.name;
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
              _pilot_update(props);
              return value;
            }
          }).fields);
        }

        props.push({
          name: name,
          kind: FVar(t, null),
          access: [ APublic ],
          meta: e != null ? [ { name: ':optional', pos: f.pos } ] : [],
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

      default:
    }

    var propType = TAnonymous(props);

    newFields = newFields.concat((macro class {
      
      @:noCompletion var _pilot_props:$propType;

      public static function _pilot_create(props) {
        return new $clsTp(props);
      } 
      
      public function new(__props:$propType) {
        _pilot_update(__props);
      }

      override function _pilot_setProperties(__props:Dynamic) {
        _pilot_props = ${ {
          expr: EObjectDecl(initializers),
          pos: Context.currentPos()
        } };
      }

    }).fields);
    
    return fields.concat(newFields);
  }

}

#end