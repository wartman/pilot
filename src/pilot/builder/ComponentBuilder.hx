#if macro
package pilot.builder;

import haxe.macro.Context;
import haxe.macro.Expr;
import pilot.builder.ClassBuilder;
import pilot.builder.HookFieldBuilder;

using haxe.macro.Tools;

// Todo: currently, the way we check `__shouldRender` is really
//       inconsitant and a bit hard to follow. Reconsider when
//       it is called.
class ComponentBuilder {

  static final ATTRS = '__attrs';
  static final INCOMING_ATTRS = '__incomingAttrs';
  static final OPTIONAL_META =  { name: ':optional', pos: (macro null).pos };

  public static function build() {
    var fields = Context.getBuildFields();
    var cls = Context.getLocalClass().get();
    var clsTp:TypePath = { pack: cls.pack, name: cls.name };
    var builder = new ClassBuilder(fields, cls);
    var props:Array<Field> = [];
    var updateProps:Array<Field> = [];
    var updates:Array<Expr> = [];
    var attributeUpdates:Array<Expr> = [];
    var initializers:Array<ObjectField> = [];
    var guards:Array<Expr> = [];
    var attrEffects:Array<Expr> = [];
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
    }

    // TODO: `inject` should be only used to inject pilot.State
    builder.addFieldBuilder({
      name: ':attribute',
      hook: Normal,
      similarNames: [
        'attribute', ':attr'
      ],
      multiple: false,
      options: [
        { name: 'optional', optional: true },
        { name: 'state', optional: true },
        { name: 'guard', optional: true, handleValue: expr -> expr },
        { name: 'effect', optional: true, handleValue: expr -> expr },
        { name: 'inject', optional: true, handleValue: expr -> expr },
        { name: 'consume', optional: true }
      ],
      build: function (options:{
        ?optional:Bool, 
        ?state:Bool,
        ?guard:Expr,
        ?effect:Expr,
        ?inject:Expr,
        ?consume:Bool
      }, builder, f) switch f.kind {
        case FVar(t, e):
          if (t == null) {
            Context.error('Types cannot be inferred for @:attribute vars', f.pos);
          }

          var name = f.name;
          var getName = 'get_${name}';
          var setName = 'set_${name}';
          var guardName = '__guard_${name}';
          var isOptional = e != null || options.optional == true;
          var init = e == null
            ? macro $i{INCOMING_ATTRS}.$name
            : macro $i{INCOMING_ATTRS}.$name == null ? ${e} : $i{INCOMING_ATTRS}.$name;
          var effect:Expr = options.effect;
          var update = macro @:pos(f.pos) value;
          var guard:Expr = options.guard != null 
            ? macro @:pos(f.pos) value != current && ${options.guard} 
            : macro @:pos(f.pos) value != current;

          if (options.inject != null) {
            isOptional = true;
            init = macro @:pos(f.pos) __context.get(${options.inject}, ${init});
            update = macro @:pos(f.pos) {
              value = __context.get(${options.inject}, value);
              value;
            }
          }

          if (options.consume) {
            if (!Context.unify(t.toType(), Context.getType('pilot.State'))) {
              Context.error('Attributes using consume MUST unify with pilot.State', f.pos);
            }
            isOptional = true;
            // todo: probably a cleaner way to get the path
            var path = t.toString();
            if (path.indexOf('<') >= 0) {
              path = path.substr(0, path.indexOf('<'));
            }
            var id = macro $p{path.split('.')}.__stateId;
            init = macro @:pos(f.pos) __context.get(${id}, ${init});
            update = macro @:pos(f.pos) {
              value = __context.get(${id}, value);
              value;
            }
          }

          if (effect != null) {
            attrEffects.push(macro {
              var value = $i{ATTRS}.$name;
              ${effect};
            });
          }
          
          f.kind = FProp('get', options.state ? 'set' : 'never', t, null);

          builder.add((macro class {

            function $getName() return $i{ATTRS}.$name;
  
            function $guardName(value, current):Bool return ${guard};
  
          }).fields);

          if (options.state) builder.add((macro class {
            function $setName(value) {
              if (this.$guardName(value, $i{ATTRS}.$name)) {
                var value = ${update};
                __updateAttributes({ $name: value });
                if (__shouldRender({ $name: value })) __requestUpdate();
              }
              return value;
            }
          }).fields);

          addProp(name, t, isOptional);
          initializers.push({
            field: name,
            expr: init
          });

          if (options.inject != null || options.consume != null) {
            attributeUpdates.push(macro {
              if (Reflect.hasField($i{INCOMING_ATTRS}, $v{name})) {
                var value = Reflect.field($i{INCOMING_ATTRS}, $v{name});
                $i{ATTRS}.$name = ${update};
              } else {
                var value = $i{ATTRS}.$name;
                $i{ATTRS}.$name = ${update};
              }
            });
          } else {
            attributeUpdates.push(macro {
              if (Reflect.hasField($i{INCOMING_ATTRS}, $v{name})) {
                switch [ 
                  $i{ATTRS}.$name, 
                  Reflect.field($i{INCOMING_ATTRS}, $v{name}) 
                ] {
                  case [ a, b ] if (a == b):
                    // noop
                  case [ current, value ]:
                    $i{ATTRS}.$name = ${update};
                }
              }
            });
          }

        default:
          Context.error('@:attribute can only be used on vars', f.pos);
      }
    });
    builder.addFieldBuilder({
      name: ':update',
      similarNames: [ 'update', ':udate', ':updat' ],
      multiple: false,
      hook: After,
      options: [],
      build: function (options:{}, builder, field) switch field.kind {
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
            __updateAttributes(incoming);
            if (__shouldRender(incoming)) {
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
      build: function (options:{}, builder, field) switch field.kind {
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
    builder.addFieldBuilder(new HookFieldBuilder(
      ':init',
      [ 'init', ':initialize' ],
      hook -> initHooks.push(hook)
    ));
    builder.addFieldBuilder(new HookFieldBuilder(
      ':effect',
      [ 'effect', ':efect', ':effct' ],
      hook -> effectHooks.push(hook)
    ));
    builder.addFieldBuilder(new HookFieldBuilder(
      ':dispose',
      [ 'dispose', ':dispse', ':dispos' ],
      hook -> disposeHooks.push(hook)
    ));
    builder.addFieldBuilder(
      new ComputedFieldBuilder(expr -> attributeUpdates.push(expr))
    );

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
          expr: macro @:pos(cls.pos) return cast new $clsTp(props, context),
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
        pos: (macro null).pos,
        kind: FFun({
          ret: macro:pilot.VNode,
          params: createParams,
          args: [
            { name: 'attrs', type: macro:$propType },
            { name: 'key', type: macro:Null<pilot.Key>, opt: true }
          ],
          expr: macro @:pos(cls.pos) return pilot.VNode.VComponent(
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

      public function new($INCOMING_ATTRS:$propType, __context:pilot.Context<Dynamic>) {
        this.__context = __context;
        this.$ATTRS = ${ {
          expr: EObjectDecl(initializers),
          pos: (macro null).pos
        } };
        $b{attrEffects};
      }

      override function __updateAttributes($INCOMING_ATTRS:Dynamic) {
        $b{attributeUpdates};
        $b{attrEffects};
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
