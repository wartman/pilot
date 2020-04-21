#if macro
package pilot.builder;

import haxe.macro.Expr;
import haxe.macro.Context;
import pilot.builder.ClassBuilder;

class AttributeBuilder {
  
  public var name:String = ':attribute';
  public var hook:FieldBuilderHook = Normal;
  public var multiple:Bool = false;
  public var similarNames = [
    'attribute', ':attr'
  ];
  public var options:Array<BuilderOption> = [
    { name: 'optional', optional: true },
    { name: 'state', optional: true },
    { name: 'guard', optional: true, handleValue: expr -> expr },
    { name: 'effect', optional: true, handleValue: expr -> expr },
    { name: 'inject', optional: true, handleValue: expr -> expr }
  ];
  
  final settings:{
    makePublic:Bool,
    propsName:String,
    initArg:String,
    updatesArg:String
  };
  final addInitializer:(field:ObjectField)->Void;
  final addProp:(name:String, type:ComplexType, isOptional:Bool, effect:Expr)->Void;
  final triggerUpdate:(attr:String)->Expr;

  public function new(addInitializer, addProp, triggerUpdate, settings) {
    this.addInitializer = addInitializer;
    this.addProp = addProp;
    this.triggerUpdate = triggerUpdate;
    this.settings = settings;
  }

  public function build(options:{ 
    ?optional:Bool, 
    ?state:Bool,
    ?guard:Expr,
    ?effect:Expr,
    ?inject:Expr
  }, builder:ClassBuilder, f:Field) {
    var initArg = settings.initArg;
    var updatedProp = settings.updatesArg;
    var propsName = settings.propsName;
    switch f.kind {
      case FVar(t, e):
        var name = f.name;
        var getName = 'get_${name}';
        var setName = 'set_${name}';
        var guardName = '__guard_${name}';
        var isOptional = e != null || options.optional == true;
        var effect:Expr = options.effect;
        var guard:Expr = options.guard != null 
          ? macro value != current && ${options.guard} 
          : macro value != current;

        if (options.inject != null) {
          isOptional = true;
          e = e != null
            ? macro @:pos(f.pos) __context.get(${options.inject}, $e)
            : macro @:pos(f.pos) __context.get(${options.inject});
          effect = effect != null
            ? macro @:pos(f.pos) __context.get(${options.inject}, ${effect})
            : macro @:pos(f.pos) __context.get(${options.inject}, value);
        }

        if (t == null) {
          Context.error('Types cannot be inferred for @${this.name} vars', f.pos);
        }

        f.kind = FProp('get', options.state ? 'set' : 'never', t, null);

        if (settings.makePublic) {
          if (f.access.indexOf(APublic) < 0) {
            f.access.push(APublic);
          }
        }

        if (e != null) {
          addInitializer({
            field: name,
            expr: macro $i{initArg}.$name != null ? $i{initArg}.$name : $e
          });
        } else {
          addInitializer({
            field: name,
            expr: macro $i{initArg}.$name
          });
        }

        addProp(name, t, isOptional, effect);
        
        builder.add((macro class {

          function $getName() return this.$propsName.$name;

          function $guardName(value, current):Bool return ${guard};

        }).fields);

        if (options.state) builder.add((macro class {
          function $setName(value) {
            if (this.$guardName(value, this.$propsName.$name)) {
              __updateAttributes({ $name: value });
              ${triggerUpdate(name)};
            }
            return value;
          }
        }).fields);

      default:
        Context.error('@${this.name} can only be used on vars', f.pos);
    }
  }


}
#end
