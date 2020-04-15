#if macro
package pilot.builder;

import haxe.macro.Context;
import haxe.macro.Expr;
import pilot.builder.ClassBuilder;
import pilot.builder.AttributeBuilder;
import pilot.builder.HookBuilder;

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
    var props:Array<Field> = [];
    var updateProps:Array<Field> = [];
    var updates:Array<Expr> = [];
    var attributeUpdates:Array<Expr> = [];
    var initializers:Array<ObjectField> = [];
    var builder = new ClassBuilder(fields, cls);
    var guards:Array<Expr> = [];
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
      attributeUpdates.push(macro {
        if (Reflect.hasField($i{INCOMING_ATTRS}, $v{name})) switch [ $i{ATTRS}.$name, Reflect.field($i{INCOMING_ATTRS}, $v{name}) ] {
          case [ a, b ] if (a == b):
          case [ _, b ]: 
            // __changed++;
            $i{ATTRS}.$name = b;
        }
      });
    }

    // todo: we can make the AttributeBuilder nicer
    builder.addFieldBuilder(new AttributeBuilder(
      expr -> initializers.push(expr),
      addProp,
      name -> macro if (__shouldRender({ $name: value })) __requestUpdate(),
      {
        makePublic: false,
        propsName: ATTRS,
        initArg: INCOMING_ATTRS,
        updatesArg: INCOMING_ATTRS
      }
    ));
    builder.addFieldBuilder({
      name: ':update',
      similarNames: [ 'update', ':udate', ':updat' ],
      multiple: false,
      hook: After,
      options: [],
      build: (options:{}, builder, field) -> switch field.kind {
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
      build: (options:{}, builder, field) -> switch field.kind {
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
    builder.addFieldBuilder(new HookBuilder(
      ':init',
      [ 'init', ':initialize' ],
      hook -> initHooks.push(hook)
    ));
    builder.addFieldBuilder(new HookBuilder(
      ':effect',
      [ 'effect', ':efect', ':effct' ],
      hook -> effectHooks.push(hook)
    ));
    builder.addFieldBuilder(new HookBuilder(
      ':dispose',
      [ 'dispose', ':dispse', ':dispos' ],
      hook -> disposeHooks.push(hook)
    ));

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
          expr: macro return cast new $clsTp(props, context),
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
        pos: cls.pos,
        kind: FFun({
          ret: macro:pilot.VNode,
          params: createParams,
          args: [
            { name: 'attrs', type: macro:$propType },
            { name: 'key', type: macro:Null<pilot.Key>, opt: true }
          ],
          expr: macro return pilot.VNode.VComponent(
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

      public function new($INCOMING_ATTRS:$propType, context:pilot.Context<Dynamic>) {
        this.__context = context;
        this.$ATTRS = ${ {
          expr: EObjectDecl(initializers),
          pos: Context.currentPos()
        } };
        // todo: init stuff
      }

      override function __updateAttributes($INCOMING_ATTRS:Dynamic) {
        $b{attributeUpdates};
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
