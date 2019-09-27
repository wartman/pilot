#if macro
package pilot2.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using haxe.macro.Tools;

class WidgetBuilder {
  
  static final initMeta = [ ':init' ];
  static final propsMeta = [ ':prop', ':property' ];
  static final stateMeta = [ ':state' ];
  static final styleMeta = [ ':style' ];

  public static function build() {
    var cls = Context.getLocalClass().get();
    var clsName = cls.pack.concat([ cls.name ]).join('_');
    var clsType = Context.getType(clsName).toComplexType();
    var isStateful = false;
    var fields = Context.getBuildFields();
    var props:Array<Field> = [];
    var constructorProps:Array<Field> = [];
    var newFields:Array<Field> = [];
    var initializers:Array<ObjectField> = [];
    var lateInitializers:Array<Expr> = [];

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
        initializers.push({
          field: name,
          expr: macro props.$name == null ? $e : props.$name
        });
      } else {
        initializers.push({
          field: name,
          expr: macro  props.$name
        });
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
            if (_pilot_currentState != null) {
              _pilot_currentState.patch();
            }
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

      case FVar(t, e) if (f.meta.exists(m -> stateMeta.has(m.name))):
        isStateful = true;
        createProperty(f, t, e, true);
      
      case FVar(t, e) if (f.meta.exists(m -> styleMeta.has(m.name))):
        f.kind = FVar(macro:pilot.Style, StyleBuilder.createNamed(
          clsName + '_' + f.name,
          e
        ));

      // case FVar(t, e) if (f.meta.exists(m -> styleSheetMeta.has(m.name))):
      //   f.kind = FVar(macro:pilot.StyleSheet, StyleBuilder.createSheet(e));
      
      // case FVar(t, e) if (f.meta.exists(m -> styleGlobalMeta.has(m.name))):
      //   f.kind = FVar(macro:pilot.Style, StyleBuilder.createNamed(
      //     clsName + '_' + f.name,
      //     e, 
      //     true
      //   ));
      //   f.meta.push({ name: ':keep', params: [], pos: f.pos });

      case FFun(_) if (f.meta.exists(m -> initMeta.has(m.name))):
        var name = f.name;
        lateInitializers.push(macro this.$name());

      default:
    }

    var propsVar = TAnonymous(props);
    var conArg = TAnonymous(constructorProps);
    var obj:Expr =  {
      expr: EObjectDecl(initializers),
      pos: cls.pos
    };

    newFields = newFields.concat((macro class {

      @:noCompletion var _pilot_props:$propsVar;

      public function new(props:$conArg) {
        _pilot_props = ${obj};
        $b{lateInitializers};
      }

    }).fields);

    if (isStateful && Context.defined('js')) {

      // todo: this isn't there yet -- eventually, the State returned by
      //       Render should handle state simialr to how Flutter does it.

      newFields = newFields.concat((macro class {

        @:noCompletion var _pilot_currentState:pilot2.WidgetState<$clsType>;

        override function render():VNode {
          _pilot_currentState = new pilot2.WidgetState(this);
          var vn:VNode = _pilot_currentState;
          _pilot_applyHooks(vn);
          vn.hooks.add(HookDestroy(_ -> {
            @:privateAccess _pilot_currentState.widget = null;
            @:privateAccess _pilot_currentState.differ = null;
            _pilot_currentState = null;
          }));
          return vn;
        }

      }).fields);

    }

    return fields.concat(newFields);
  }

}
#end
