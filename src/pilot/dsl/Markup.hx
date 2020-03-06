#if macro
package pilot.dsl;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.PositionTools;

class Markup {

  static final defaultControlFlow:Bool = Context.defined('pilot-markup-no-inline-control-flow');

  /**
    Parse an expression using the default markup parser.
  **/
  public static function parse(expr:Expr, ?noInlineControlFlow:Bool) {
    expr = switch expr {
      case macro @:markup ${e}: e;
      default: expr;
    }
    
    var info = expr.pos.getInfos();
    switch expr.expr {
      case EConst(CString(s)):
        try {
          var parser = new MarkupParser({
            noInlineControlFlow: noInlineControlFlow != null
              ? noInlineControlFlow
              : defaultControlFlow
          }, s, info.file, info.min);
          var ast = parser.parse();
          var generator = new MarkupGenerator(ast, expr.pos);
          return generator.generate();
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
