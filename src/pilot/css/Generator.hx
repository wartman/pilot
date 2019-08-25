#if macro

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

  public static function generateGlobal(exprs:Array<CssExpr>):Expr {
    var children:Array<Expr> = [];
    for (rule in exprs) switch rule {
      case EProperty(name, value):
        throw 'Global styles cannot have properties at the root level';
      default:
        generateChild(null, exprs, children);
    }
    return macro [ $a{ children } ].join('\n');
  }

  public static function generateChild(name:Null<String>, exprs:Array<CssExpr>, children:Array<Expr>):Expr {
    var declaration:Array<Expr> = [];
    for (rule in exprs) switch rule {
      case EDeclaration(selectors, properties):
        for (s in selectors) {
          var subName = if (name == null) {
            s; 
          } else if (s.contains('&')) {
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

#end