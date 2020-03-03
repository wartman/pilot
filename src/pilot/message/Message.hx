package pilot.message;

#if !macro

import pilot.Plugin;
import pilot.Component;
import pilot.Signal;

@:autoBuild(pilot.message.Message.build())
class Message<Action, Data> implements Plugin {

  var __component:Component;
  var __store:Store<Action, Data>;
  var __subscription:SignalSubscription<Data>;

  public function __connect(component:Component) {
    __component = component;
    __store = __component.__context.get(Store.ID);
    
    if (__store == null) {
      // todo: better errors
      throw 'No store found -- make sure all Messages are inside a StoreProvider or ConnectedRoot';
    }

    __maybeAddUpdaterToStore(__store);
    __updateState(__store.data);
    __subscription = __store.subscribe(__update);
    __component.__onDisposal.addOnce(__handleDisposal);
  }

  public function __disconnect(component:Component) {
    if (component == __component) {
      __subscription.cancel();
      __component.__onDisposal.remove(__handleDisposal);
    }
  }

  function __handleDisposal(_) {
    __subscription.cancel();
  }

  function __maybeAddUpdaterToStore(store:Store<Action, Data>) {
    // handled by macro
  }

  function __update(data:Data) {
    if (__updateState(data)) {
      __component.__requestUpdate({});
    }
  }

  function __updateState(data:Data):Bool {
    // handled by macro
    return false;
  }

}

#else

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using haxe.macro.TypeTools;

class Message {
  
  static final stateMeta = [ ':state' ];
  static final sendMeta = [ ':send' ];
  static final updateMeta = [ ':update' ];

  public static function build() {
    var cls = Context.getLocalClass().get();
    var fields = Context.getBuildFields();

    // todo: make this more robust
    var action = cls.superClass.params[0].toComplexType();
    var data = cls.superClass.params[1].toComplexType();
    
    var stateUpdates:Array<Expr> = [];
    var stateProps:Array<Field> = [];
    var updateMeta = cls.meta.get().find(m -> updateMeta.has(m.name));

    if (updateMeta == null) {
      Context.error('All messages require an `@:update`', cls.pos);
    }
    var updater = switch updateMeta.params {
      case [ e ]: e;
      default:
        Context.error('Invalid number of params for the updater', updateMeta.pos);
        null;
    }

    for (f in fields) switch f.kind {

      case FVar(t, e) if (f.meta.exists(m -> stateMeta.has(m.name))):
        var name = f.name;
        var getterName = 'get_${name}';
        var params = f.meta.find(m -> stateMeta.has(m.name)).params;
        var mapping = macro Reflect.field(data, $v{name});

        for (p in params) switch p {
          case macro map = ${e}: mapping = e;
          default:
            Context.error('Invalid @:state option', p.pos);
        }

        f.access = [ APublic ];
        f.kind = FProp('get', 'null', t, null);
        stateProps.push({
          name: name,
          kind: FVar(t, null),
          access: [ APublic ],
          meta: [ { name: ':optional', pos: f.pos } ],
          pos: (macro null).pos
        });
        fields = fields.concat((macro class {
          function $getterName() return __state.$name;
        }).fields);
        
        stateUpdates.push(macro @:pos(f.pos) {
          var __s = ${mapping};
          if (__s != null) switch [ __state.$name, __s ] {
            case [ a, b ] if (a == b):
            case [ _, b ]: 
              __state.$name = b;
              changed = true;
          }
        });
      
      case FFun(func) if (f.meta != null && f.meta.exists(m -> sendMeta.has(m.name))):
        var e = func.expr;
        var ret = func.ret;

        func.ret = macro:Void;
        func.expr = macro @:pos(e.pos) {
          var closure = function():$ret return ${e};
          __store.dispatch(closure());
        }

      default:

    }

    var state = TAnonymous(stateProps);
    var path = macro $p{cls.pack.concat([ cls.name ])};

    return fields.concat((macro class {

      public static function __updateData(message:$action, data:$data):Null<$data> 
        return ${updater};

      public function new() {}

      private var __state:$state = {};

      override function __maybeAddUpdaterToStore(store) {
        if (!store.hasUpdater(${path})) {
          store.addUpdater(${path});
        }
      }

      override function __updateState(data) {
        var changed = false;
        $b{stateUpdates};
        return changed;
      }

    }).fields);
  }

}

#end
