package pilot;

class Html {

  #if !macro macro #end public static function create(e, ?options:haxe.macro.Expr) {
    var noInlineControlFlow:Bool = false;

    switch options.expr {
      case EObjectDecl(fields): for (f in fields) switch f.field {
        case 'noInlineControlFlow': switch f.expr {
          case macro true: noInlineControlFlow = true;
          case macro false: noInlineControlFlow = false;
          default: haxe.macro.Context.error('The option `noInlineControlFlow` expects a Bool', f.expr.pos);
        }
      }
      case EConst(CIdent('null')):
        // Noop
      default:
        haxe.macro.Context.error('Expected { ?noInlineControlFlow:Bool }', options.pos);
    }

    return pilot.dsl.Markup.parse(e, noInlineControlFlow);
  }

}
