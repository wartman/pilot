#if macro
package pilot.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;

class WidgetBuilder {

  static final initMeta = [ ':init' ];
  static final propsMeta = [ ':prop', ':property' ];
  static final stateMeta = [ ':state' ];
  static final styleMeta = [ ':style' ];
  static final styleSheetMeta = [ ':style.sheet' ];
  static final styleGlobalMeta = [ ':style.global' ];

  public static function build(options:{ stateful:Bool }) {
    var cls = Context.getLocalClass().get();
    var clsName = cls.pack.concat([ cls.name ]).join('_');
    var fields = Context.getBuildFields();
    var props:Array<Field> = [];
    var constructorProps:Array<Field> = [];
    var newFields:Array<Field> = [];
    var initializers:Array<Expr> = [];

    function createProperty(f:Field, t:ComplexType, e:Expr, isState:Bool) {
      f.kind = isState 
        ? FProp('get', 'set', t, null)
        : FProp('get', 'never', t, null);
      var name = f.name;
      var isOptional = f.meta.exists(m -> m.name == ':optional');
      var getName = 'get_${name}';
      var setName = 'set_${name}';

      if (e != null) {
        isOptional = true;
        initializers.push(macro _pilot_props.$name = props.$name == null ? $e : props.$name);
      } else {
        initializers.push(macro _pilot_props.$name = props.$name);
      }

      var prop = {
        name: name,
        kind: FVar(t, null),
        access: [ APublic ],
        meta: isOptional ? [ { name: ':optional', pos: f.pos } ] : [],
        pos: f.pos
      };
      constructorProps.push(prop);
      props.push(prop);

      if (isState) {
        newFields = newFields.concat((macro class {
          function $setName(value) {
            _pilot_props.$name = value;
            patch();
            return value;
          }
          inline function $getName() return _pilot_props.$name;
        }).fields);
      } else {
        newFields = newFields.concat((macro class {
          inline function $getName() return _pilot_props.$name;
        }).fields);
      }
    }

    for (f in fields) switch (f.kind) {
      case FVar(t, e) if (f.meta.exists(m -> propsMeta.has(m.name))):
        createProperty(f, t, e, false);

      case FVar(t, e) if (options.stateful && f.meta.exists(m -> stateMeta.has(m.name))):
        createProperty(f, t, e, true);
      
      case FVar(t, e) if (f.meta.exists(m -> styleMeta.has(m.name))):
        f.kind = FVar(macro:pilot.Style, StyleBuilder.createNamed(clsName + '_' + f.name, e));

      case FVar(t, e) if (f.meta.exists(m -> styleSheetMeta.has(m.name))):
        f.kind = FVar(macro:pilot.StyleSheet, StyleBuilder.createSheet(e));
      
      case FVar(t, e) if (f.meta.exists(m -> styleGlobalMeta.has(m.name))):
        f.kind = FVar(macro:pilot.Style, StyleBuilder.createNamed(clsName + '_' + f.name, e, true));
        f.meta.push({ name: ':keep', params: [], pos: f.pos });

      case FFun(_) if (f.meta.exists(m -> initMeta.has(m.name))):
        var name = f.name;
        initializers.push(macro this.$name());

      default:
    }

    if (!fields.exists(f -> f.name == 'getKey')) {
      newFields.push((macro class {
        public function getKey() {
          return null;
        }
      }).fields.pop());
    }

    var propsVar = TAnonymous(props);
    var conArg = TAnonymous(constructorProps);
    newFields = newFields.concat((macro class {

      var _pilot_props:$propsVar;

      public function new(props:$conArg) {
        _pilot_props = cast {};
        $b{initializers};
      }

    }).fields);

    return fields.concat(newFields);
  }

}
#end
