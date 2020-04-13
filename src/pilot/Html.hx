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
  
  #if !macro

    inline public static function h<Node:{}>(
      tag:String,
      attrs:{}, 
      ?children:Array<VNode>,
      ?key:Key
    ):VNode {
      return VNative(NodeType.get(tag), attrs, children, key);
    }

    inline public static function text<Node:{}>(content:String, ?key:Key):VNode {
      return VNative(TextType, { content: content }, [], key);
    }

  #end

}
