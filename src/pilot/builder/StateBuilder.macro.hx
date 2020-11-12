package pilot.builder;

import haxe.macro.Context;
import haxe.macro.Expr;
import pilot.builder.ClassBuilder;
import pilot.builder.HookFieldBuilder;

using haxe.macro.Tools;

// Todo: a lot of this could be unified with ComponentBuilder
class StateBuilder {

  static final ATTRS = '__attrs';
  static final INCOMING_ATTRS = '__incomingAttrs';
  static final OPTIONAL_META =  { name: ':optional', pos: (macro null).pos };

  public static function build() {
    var fields = Context.getBuildFields();
    var cls = Context.getLocalClass().get();
    var clsTp:TypePath = { pack: cls.pack, name: cls.name };
    var builder = new ClassBuilder(fields, cls);
    var initializers:Array<ObjectField> = [];
    var props:Array<Field> = [];
    var updateProps:Array<Field> = [];
    var attributeUpdates:Array<Expr> = [];
    var initHooks:Array<Hook> = [];
    var disposeHooks:Array<Hook> = [];
    

    function prepareHooks(hooks:Array<Hook>):Array<Expr> {
      hooks.sort((a, b) -> {
        return if (a.priority < b.priority) -1
        else if (a.priority > b.priority) 1
        else 0;
      });
      return hooks.map(h -> h.expr);
    }

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
    
    builder.addFieldBuilder({
      name: ':attribute',
      hook: Normal,
      similarNames: [
        'attribute', ':attr'
      ],
      multiple: false,
      options: [
        { name: 'optional', optional: true },
        { name: 'consume', optional: true },
      ],
      build: function (options:{
        ?optional:Bool, 
        ?consume:Bool 
      }, builder, f) switch f.kind {
        case FVar(t, e):
          if (t == null) {
            Context.error('Types cannot be inferred for @:attribute vars', f.pos);
          }

          var name = f.name;
          var getName = 'get_${name}';
          var isOptional = e != null || options.optional == true;
          var update = macro @:pos(f.pos) value;
          var init = e == null
            ? macro $i{INCOMING_ATTRS}.$name
            : macro $i{INCOMING_ATTRS}.$name == null ? ${e} : $i{INCOMING_ATTRS}.$name;

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

          f.kind = FProp('get', 'never', t, null);
          if (f.access.indexOf(APublic) < 0) {
            f.access.push(APublic);
          }

          builder.add((macro class {
            function $getName() return $i{ATTRS}.$name;
          }).fields);

          addProp(name, t, isOptional);
          initializers.push({
            field: name,
            expr: init
          });

          if (options.consume != null) {
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
      name: ':transition',
      similarNames: [ 'transition', ':update', ':transtion' ],
      multiple: false,
      hook: After,
      options: [
        { name: 'silent', optional: true }
      ],
      build: function (options:{
        ?silent:Bool
      }, builder, field) switch field.kind {
        case FFun(func):
          if (func.ret != null) {
            Context.error('@:transition functions should not define their return type manually', field.pos);
          }
          var updatePropsRet = TAnonymous(updateProps);
          var e = func.expr;
          var silent = options.silent == true ? macro true : macro false;
          func.ret = macro:Void;
          func.expr = macro {
            inline function closure():$updatePropsRet ${e};
            var incoming = closure();
            update(incoming, ${silent});
          }
        default:
          Context.error('@:transition must be used on a method', field.pos);
      }
    });
    builder.addFieldBuilder(
      new ComputedFieldBuilder(expr -> attributeUpdates.push(expr), true)
    );
    builder.addFieldBuilder(new HookFieldBuilder(
      ':init',
      [ 'init', ':initialize' ],
      hook -> initHooks.push(hook)
    ));
    builder.addFieldBuilder(new HookFieldBuilder(
      ':dispose',
      [ 'dispose', ':dispse', ':dispos' ],
      hook -> disposeHooks.push(hook)
    ));

    builder.run();
    
    var initProps = props.concat([
      {
        name: 'children',
        kind: FVar(macro:pilot.Children),
        access: [ APublic ],
        meta: [],
        pos: (macro null).pos
      }
    ]);
    var initPropsType = TAnonymous(initProps);
    var propsType = TAnonymous(props);
    var updatePropsType = TAnonymous(updateProps);
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
          args: [
            { name: 'props', type: macro:$initPropsType },
            { name: 'context', type: macro:pilot.Context<Node> }
          ],
          // Todo: figure out how we can NOT have to use `cast` here
          expr: macro @:pos(cls.pos) return cast new $clsTp(props, context),
          ret: macro:pilot.Wire<Node, $initPropsType>
        })
      },

      {
        name: 'provide',
        pos: (macro null).pos,
        access: [ APublic, AStatic ],
        kind: FFun({
          params: createParams,
          args: [
            { name: 'attrs', type: macro:$initPropsType },
            { name: 'key', type: macro:Null<pilot.Key>, opt: true }
          ],
          expr: macro @:pos(cls.pos) return pilot.VNode.VComponent(
            $p{ cls.pack.concat([ cls.name ]) },
            attrs,
            key
          ),
          ret: macro:pilot.VNode
        })
      }

    ]);

    builder.add((macro class {

      public static inline final __stateId:String = $v{cls.pack.concat([ cls.name ]).join('.')};

      var $ATTRS:$propsType;

      public function new($INCOMING_ATTRS:$initPropsType, __context:pilot.Context<Dynamic>) {
        this.$ATTRS = ${ {
          expr: EObjectDecl(initializers),
          pos: (macro null).pos
        } };
        __component = new pilot.State.StateComponent({ 
          children: $i{INCOMING_ATTRS}.children 
        }, __setContext(__context));
        $b{prepareHooks(initHooks)}
      }

      function update($INCOMING_ATTRS:$updatePropsType, silent:Bool = false) {
        $b{attributeUpdates};
        if (!silent) @:privateAccess __component.__requestUpdate();
      }

      override function __update(attrs:Dynamic, ?_, context, parent, effectQueue) {
        update(attrs, true);
        super.__update(attrs, _, context, parent, effectQueue);
      }

      override function __register() {
        __context.set(__stateId, this);
      }

      override function __destroy() {
        $b{prepareHooks(disposeHooks)};
        super.__destroy();
      }

    }).fields);

    return builder.export();
  }

}
