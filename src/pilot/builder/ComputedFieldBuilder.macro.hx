package pilot.builder;

import haxe.macro.Context;
import haxe.macro.Expr;
import pilot.builder.ClassBuilder;

class ComputedFieldBuilder {
  
  
  public var name:String = ':computed';
  public var similarNames:Array<String> = [
    'computed', ':comptued' // etc
  ];
  public var hook:FieldBuilderHook = After;
  public var multiple:Bool = false;
  public var options:Array<BuilderOption> = [];
  var triggerInvalid:(expr:Expr)->Void;
  final forcePublic:Bool;

  public function new(triggerInvalid, forcePublic = false) {
    this.triggerInvalid = triggerInvalid;
    this.forcePublic = forcePublic;
  }

  public function build(options:{}, builder:ClassBuilder, f:Field) {
    switch f.kind {
      case FVar(t, e):
        if (t == null) {
          Context.error('Types cannot be inferred for @${this.name} vars', f.pos);
        }
        if (e == null) {
          Context.error('@${this.name} reuires an expression', f.pos);
        }

        var name = f.name;
        var getName = 'get_${name}';
        var computedName = '__computed_${name}';

        f.kind = FProp('get', 'never', t, null);

        if (forcePublic && f.access.indexOf(APublic) < 0) {
          f.access.push(APublic);
        }

        triggerInvalid(macro @:pos(f.pos) this.$computedName = null);

        builder.add((macro class {

          var $computedName:$t = null;

          public function $getName():$t {
            if (this.$computedName == null) {
              this.$computedName = ${e};
            }
            return this.$computedName;
          }

        }).fields);

      default:
        Context.error('@${this.name} can only be used on methods', f.pos);
    }
  }

}
