#if macro
package pilot.dsl;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.PositionTools;

class Markup {

  static final noInlineControlFlow:Bool = Context.defined('pilot-markup-no-inline-control-flow');
  
  public static function parse(expr:Expr) {
    expr = switch expr {
      case macro @:markup ${e}: e;
      default: expr;
    }
    
    var info = expr.pos.getInfos();
    switch expr.expr {
      case EConst(CString(s)):
        try {
          var parser = new MarkupParser(s, info.file, info.min);
          parser.noInlineControlFlow = noInlineControlFlow;
          var ast = parser.parse();
          return new MarkupGenerator(ast, expr.pos).generate();
        } catch (e:DslError) {
          Context.error(e.message, Context.makePosition({
            min: e.pos.min,
            max: e.pos.max,
            file: info.file
          }));
          return macro null;
        }
      default:
        Context.error('Invalid expression', expr.pos);
        return macro null;
    }
  }

}
#end
