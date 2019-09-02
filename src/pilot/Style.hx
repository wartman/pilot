package pilot;

using StringTools;
using Lambda;

abstract Style(String) to String {

  @:from public inline static function ofArray(styles:Array<Style>):Style {
    return compose(styles);
  }

  public static macro function global(rules) {
    pilot.macro.StyleBuilder.create(rules, true);
    return macro null;
  }

  public static macro function create(rules:haxe.macro.Expr.ExprOf<Dynamic>) {
    var name = pilot.macro.StyleBuilder.create(rules);
    return macro @:pos(rules.pos) new pilot.Style(${name});
  }

  public inline static function compose(styles:Array<Style>):Style {
    return styles.fold((ret, value:Style) -> value.add(ret), new Style(''));
  }

  public inline static function applyStyle(vnode:VNode, style:Style):VNode {
    vnode.style = compose([ vnode.style, style ]);
    return vnode;
  }

  public inline function new(name:String) {
    this = name;
  }

  @:op(a + b)
  public inline function add(style:Style):Style {
    return new Style(switch [ this, (style:String) ] {
      case [ null, v ] | [ v, null ]: v;
      case [ a, b ] if (!a.contains(b)): '$a $b';
      default: this;
    });
  }

}
