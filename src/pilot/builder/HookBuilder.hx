#if macro
package pilot.builder;

import haxe.macro.Expr;
import haxe.macro.Context;
import pilot.builder.ClassBuilder;

typedef Hook = { expr:Expr, priority:Int }; 

class HookBuilder {
  
  public var name:String;
  public var similarNames:Array<String>;
  public var hook:FieldBuilderHook = After;
  public var multiple:Bool = false;
  public var options = [
    { name: 'priority', optional: true }
  ];
  
  final register:(hook:Hook)->Void;

  public function new(name, similarNames, register) {
    this.name = name;
    this.similarNames = similarNames;
    this.register = register;
  }

  public function build(options:{ ?priority:Int }, builder:ClassBuilder, f:Field) {
    var priority:Int = options.priority != null ? options.priority : 10;
    switch f.kind {
      case FFun(func):
        if (func.args.length > 0) {
          Context.error('@${name} methods cannot accept arguments', f.pos);
        }
        var name = f.name;
        register({
          expr: macro this.$name(), 
          priority: priority
        });
      default:
        Context.error('@${name} can only be used on methods', f.pos);
    }
  }

}
#end
