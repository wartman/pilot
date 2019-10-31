package pilot;

#if !macro

import js.html.Node;
import pilot.diff.Widget;

@:autoBuild(pilot.Component.build())
class Component extends 
  #if (js && !nodejs)
    Widget<Node>
  #else
    Widget<String>
  #end
{ }

#else

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using haxe.macro.ComplexTypeTools;

class Component {

  public static function build() {
    var cls = Context.getLocalClass().get();
    var clsTp:TypePath = {
      pack: cls.pack,
      name: cls.name
    };
    var fields = Context.getBuildFields();
    var newFields:Array<Field> = [];
    var props:Array<Field> = [];
    var initializers:Array<Expr> = [];
    
    for (f in fields) switch (f.kind) {
      case FVar(t, e):
        if (f.meta.exists(m -> m.name == ':attribute' || m.name == ':attr')) {
          f.kind = FProp('get', 'set', t, null);
          var name = f.name;
          var getName = 'get_${name}';
          var setName = 'set_${name}';
          if (e != null) {
            initializers.push(macro _pilot_props.$name = __props.$name != null ? __props.$name : $e);
          } else {
            initializers.push(macro _pilot_props.$name = __props.$name);
          }
          newFields = newFields.concat((macro class {
            function $setName(value) {
              _pilot_props.$name = value;
              _pilot_patch();
              return value;
            }
            function $getName() return _pilot_props.$name;
          }).fields);
          props.push({
            name: name,
            kind: FVar(t, null),
            access: [ APublic ],
            meta: e != null ? [ { name: ':optional', pos: f.pos } ] : [],
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
        _pilot_props = cast {};
        $b{initializers};
      }

      override function _pilot_setProperties(__props:Dynamic) {
        _pilot_props = __props;
      }

    }).fields);
    
    return fields.concat(newFields);
  }

}

#end