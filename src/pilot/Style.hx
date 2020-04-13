package pilot;


using Lambda;

abstract Style(String) to String {

  #if !macro macro #end public static function create(e, options:haxe.macro.Expr.ExprOf<{ ?global:Bool, ?embed:Bool }>) {
    var embed = false;
    var global = false;

    switch options.expr {
      case EObjectDecl(fields): for (f in fields) switch f.field {
        case 'embed': switch f.expr {
          case macro true: embed = true;
          case macro false: embed = false;
          default: haxe.macro.Context.error('The option `embed` expects a Bool', f.expr.pos);
        }
        case 'global': switch f.expr {
          case macro true: global = true;
          case macro false: global = false;
          default: haxe.macro.Context.error('The option `global` expects a Bool', f.expr.pos);
        }
        default:
          haxe.macro.Context.error('Invalid option: ${f.field}', options.pos);
      }
      case EConst(CIdent('null')):
        // Noop
      default:
        haxe.macro.Context.error('Expected { ?global:Bool, ?embed:Bool }', options.pos);
    }

    var style = pilot.dsl.Css.parse(e, embed, global);
    return macro @:pos(e.pos) (${style}:pilot.Style);
  }

  @:from public inline static function ofArray(styles):Style {
    return compose(styles);
  }

  public inline static function compose(styles:Array<Null<Style>>):Style {
    return styles.fold((value:Style, next:Style) -> next.add(value), new Style(''));
  }

  public inline function new(name:String) {
    this = name;
  }

  @:op(a + b)
  public function add(style:Style):Style {
    return new Style(switch [ this, (style:String) ] {
      case [ null, v ] | [ v, null ]: v;
      case [ a, b ] if (a.length == 0): b;
      case [ a, b ] if (b.length == 0): a;
      case [ a, b ] if (!a.split(' ').has(b)): '$a $b';
      default: this;
    });
  }

}
