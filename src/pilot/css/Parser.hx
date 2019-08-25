package pilot.css;

import haxe.macro.Context;
import haxe.macro.Expr;

using pilot.css.PropertyTools;
using haxe.macro.Tools;

class Parser {
  
  public static function parse(expr:Expr) {
    var css:Array<CssExpr> = [];
    switch expr.expr {

      case EBlock(exprs): for (e in exprs) {
        switch e {
          case macro $name = $value:
            css.push(parseProperty(name, value));
          case macro @select($name) $rules:
            css.push(CssExpr.EDeclaration(parseSelector(name), parse(rules)));
          case macro @media($a{args}) $rules:
            Context.error('Media not implemented yet', e.pos);
          default:
            Context.error('Invalid expression', e.pos);
        }
      }

      default:
        Context.error('Invalid expression', expr.pos);

    }

    return css;
  }

  static function parseProperty(name:Expr, value:Expr):CssExpr {
    return switch value.expr {
      case EBlock(_): 
        CssExpr.EDeclaration(parseSelector(name), parse(value));
      default:
        CssExpr.EProperty(parsePropertyName(name), parseValue(value));
    }
  }

  static function parseSelector(e:Expr):Array<String> {
    return switch e.expr {
      case EConst(CIdent(s)) | EConst(CString(s)): 
        [ s ];
      case EArrayDecl(values):
        var sel:Array<String> = [];
        for (v in values) {
          sel = sel.concat(parseSelector(v));
        }
        sel;
      default:
        Context.error('Invalid selector', e.pos);
        [];
    }
  }

  static function parsePropertyName(e:Expr):String {
    return switch e.expr {
      case EConst(CIdent(s)): s.toKebabCase();
      case EConst(CString(s)): s;
      default:
        Context.error('Invalid property name', e.pos);
        '';
    }
  }

  static function parseValue(e:Expr):CssExpr.Value {
    return switch e.expr {
      case EConst(c): switch c {
        case CString(s) | CInt(s): 
          CssExpr.Value.VConst(s);
        case CIdent(b):
          // var f = Context.getLocalClass().get().findField(b, true);
          // if (f == null) {
          //   Context.error('The field ${b} does not exist', e.pos);
          // }
          // if (!f.isFinal) {
          //   Context.error('Fields used in pilot.Style MUST be final', e.pos);
          // }
          CssExpr.Value.VVariable(e);
        default: null;
      }
      case EField(a, b):
        // // todo: this has to be overkill
        // //       also, should we be checking this in the parser?
        // function extract(e:Expr):String {
        //   return switch e.expr {
        //     case EField(a, b): 
        //       extract(a) + '.' + b;
        //     case EConst(CIdent(s)): 
        //       s;
        //     default:
        //       Context.error('Invalid rule', e.pos);
        //       null;
        //   }
        // }
        // var typeName = extract(a);
        // if (typeName.indexOf('.') < 0) {
        //   typeName = getTypePath(typeName, Context.getLocalImports());
        // }
        // var type = try {
        //   Context.getType(typeName).getClass();
        // } catch (_:String) {
        //   Context.error('The type ${typeName} was not found', e.pos);
        // }
        // var f = type.findField(b, true);
        // if (f == null) {
        //   Context.error('The field ${typeName}.${b} does not exist', e.pos);
        // }
        // if (!f.isFinal) {
        //   Context.error('Fields used in pilot.Style MUST be final', e.pos);
        // }
        CssExpr.Value.VVariable(e);
      default: null;
    }
  }

  // // todo: this has to be overkill.
  // static function getTypePath(name:String, imports:Array<ImportExpr>):String {
  //   // check imports
  //   for (i in imports) switch i.mode {
  //     case IAsName(n):
  //       if (n == name) {
  //         var name = i.path[i.path.length - 1].name; 
  //         var pack = [ for (index in 0...i.path.length-1) i.path[index].name ];
  //         return pack.concat([ name ]).join('.');
  //       }
  //     default:
  //       var n = i.path[i.path.length - 1].name;
  //       if (n == name) {
  //         var pack = [ for (index in 0...i.path.length-1) i.path[index].name ];
  //         return pack.concat([ name ]).join('.');
  //       }
  //   }

  //   // If not found, assume local or full type path.
  //   return name;
  // }
  
}