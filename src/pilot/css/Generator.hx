package pilot.css;

import haxe.macro.Expr;

using StringTools;

class Generator {
  
  public static function generate(name:String, exprs:Array<CssExpr>):Expr {
    var children:Array<Expr> = [];
    var out = generateChild(name, exprs, children);
    return if (children.length > 0) {
      children.unshift(out);
      macro [ $a{ children } ].join('\n');
    } else {
      out;
    }
  }

  public static function generateChild(name:String, exprs:Array<CssExpr>, children:Array<Expr>):Expr {
    var declaration:Array<Expr> = [];
    for (rule in exprs) switch rule {
      case EDeclaration(selectors, properties):
        for (s in selectors) {
          var subName = if (s.contains('&')) {
            s.replace('&', name);
          } else {
            '$name $s';
          }
          children.push(generateChild(subName, properties, children));
        }
      case EProperty(name, value):
        var s = switch value {
          case VConst(s): 
            declaration.push(macro $v{'${name}: ${s};'});
          case VVariable(e):
            declaration.push(macro $v{'${name}: '} + ${e} + ';');
        }
    }
    return macro $v{'${name} {\n  '} + [ $a{declaration} ].join('\n  ') + '\n}';
  }

}
