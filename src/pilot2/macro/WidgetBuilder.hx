#if macro
package pilot2.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using pilot2.macro.MetaTools;
using haxe.macro.Tools;

class WidgetBuilder {
  
  static final initMeta = [ ':init' ];
  static final styleMetaPrefix = [ ':style' ];
  static final propsMetaPrefix = [ ':prop', ':property' ];
  static final hookMetaPrefix = [ ':hook' ];

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
    var hooks:Array<Expr> = [];

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
      case FVar(t, e) if (f.meta.hasMetaByPrefix(propsMetaPrefix)):
        var meta = f.meta.getMetaByPrefix(propsMetaPrefix);
        var parts = meta.name.split('.');

        if (parts.length == 1) {
          createProperty(f, t, e, false);
        } else switch parts[1] {
          case 'state':
            isStateful = true;
            createProperty(f, t, e, true);
          default:
            Context.error('Only `@:prop` or `@:prop.state` is allowed', meta.pos);
        }
      
      case FVar(t, e) if (f.meta.hasMetaByPrefix(styleMetaPrefix)):
        var meta = f.meta.getMetaByPrefix(styleMetaPrefix);
        var parts = meta.name.split('.');
        if (parts.length == 1) {
          f.kind = FVar(macro:pilot.Style, StyleBuilder.createNamed(
            clsName + '_' + f.name,
            e
          ));
        } else switch parts[1] {
          case 'global': 
            f.kind = FVar(macro:pilot.Style, StyleBuilder.createNamed(
              clsName + '_' + f.name,
              e, 
              true
            ));
            f.meta.push({ name: ':keep', params: [], pos: f.pos });
          default:
            Context.error('Only `@:style` or `@:style.global` is allowed', meta.pos);
        }

      case FFun(_) if (f.meta.hasMetaByPrefix(initMeta)):
        var name = f.name;
        lateInitializers.push(macro this.$name());

      case FFun(_) if (f.meta.hasMetaByPrefix(hookMetaPrefix)):
        var meta = f.meta.getMetaByPrefix(hookMetaPrefix);
        var parts = meta.name.split('.');
        var name = f.name;
        if (parts.length == 1) {
          Context.error('You must specify a specific hook (such as `@:hook.pre`, `@:hook.post`, etc.)', meta.pos);
        } else switch parts[1] {
          case 'pre':
            hooks.push(macro @:pos(f.pos) vNode.hooks.add(HookPre($i{name})));
          case 'post':
            hooks.push(macro @:pos(f.pos) vNode.hooks.add(HookPost($i{name})));
          case 'prePatch':
            hooks.push(macro @:pos(f.pos) vNode.hooks.add(HookPrePatch($i{name})));
          case 'postPatch':
            hooks.push(macro @:pos(f.pos) vNode.hooks.add(HookPostPatch($i{name})));
          case 'remove':
            hooks.push(macro @:pos(f.pos) vNode.hooks.add(HookRemove($i{name})));
          case 'destroy':
            hooks.push(macro @:pos(f.pos) vNode.hooks.add(HookDestroy($i{name})));
          case 'create':
            hooks.push(macro @:pos(f.pos) vNode.hooks.add(HookCreate($i{name})));
          case 'udpate':
            hooks.push(macro @:pos(f.pos) vNode.hooks.add(HookUpdate($i{name})));
          case 'insert':
            hooks.push(macro @:pos(f.pos) vNode.hooks.add(HookInsert($i{name})));
          default:
            Context.error('Invalid hook -- must be one of: pre, post, prePatch, postPatch, remove, destroy, create, udpate, or insert', meta.pos);
        }

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

      override function _pilot_applyHooks(vNode:VNode) {
        $b{hooks};
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

          function cleanup(vn:VNode) {
            if (
              _pilot_currentState == null
              // Only remove if vn == the vnode being patched out
              || @:privateAccess _pilot_currentState.vNode != vn 
            ) return;
            @:privateAccess _pilot_currentState.widget = null;
            @:privateAccess _pilot_currentState.differ = null;
            _pilot_currentState = null;
          };

          vn.hooks.add(HookDestroy(cleanup));
          vn.hooks.add(HookPostPatch((oldVn, _) -> cleanup(oldVn)));
          return vn;
        }

      }).fields);

    }

    return fields.concat(newFields);
  }

}
#end