package pilot;

class Template {
  
  macro public static function html(expr) {
    expr = switch expr {
      case macro @:markup ${e}: e;
      default: expr;
    }
    
    var info = haxe.macro.PositionTools.getInfos(expr.pos);
    switch expr.expr {
      case EConst(CString(s)):
        try {
          var ast = new pilot.dsl.MarkupParser(s, info.file, info.min).parse();
          return new pilot.target.dom.DomGenerator(ast, expr.pos).generate();
        } catch (e:pilot.dsl.DslError) {
          haxe.macro.Context.error(e.message, haxe.macro.Context.makePosition({
            min: e.pos.min,
            max: e.pos.max,
            file: info.file
          }));
          return macro null;
        }
      default:
        haxe.macro.Context.error('Invalid expression', expr.pos);
        return macro null;
    }
  }

}
