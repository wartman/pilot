#if macro

package pilot.dsl;

import haxe.macro.Expr;
import haxe.macro.Context;
import pilot.dsl.MarkupParser;
import pilot.dsl.MarkupGenerator;

using haxe.macro.PositionTools;

class MarkupFactory {
  
  final attributeMacros:Map<String, MarkupMacro>;
  final options:MarkupParserOptions;
  
  public function new(?macros, ?options) {
    attributeMacros = macros == null ? [] : macros;
    this.options = options == null ? {
      noInlineControlFlow: false
    } : options;
  }

  public function create(expr:Expr) {
    expr = switch expr {
      case macro @:markup ${e}: e;
      default: expr;
    }
    
    var info = expr.pos.getInfos();
    switch expr.expr {
      case EConst(CString(s)):
        try {
          var parser = new MarkupParser(options, s, info.file, info.min);
          var ast = parser.parse();
          var generator = new MarkupGenerator(ast, expr.pos, attributeMacros);
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
