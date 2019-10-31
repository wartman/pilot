package pilot;

using Lambda;

abstract Style(String) to String {
  
  /**
    Create rules.
  **/
  public static macro function create(rules:haxe.macro.Expr.ExprOf<Dynamic>) {
    return pilot.macro.StyleBuilder.create(rules);
  }

  /**
    Only outputs rules for the JS target.
  **/
  public static macro function embed(rules:haxe.macro.Expr.ExprOf<Dynamic>) {
    if (haxe.macro.Context.defined('js'))
      return pilot.macro.StyleBuilder.create(rules, false, true);
    else
      return macro null;
  }
  
  public static macro function global(rules) {
    return pilot.macro.StyleBuilder.create(rules, true);
  }

  /**
    Only outputs global rules for the JS target.
  **/
  public static macro function embedGlobal(rules:haxe.macro.Expr.ExprOf<Dynamic>) {
    return if (haxe.macro.Context.defined('js'))
      pilot.macro.StyleBuilder.create(rules, true, true);
    else
      return macro null;

  }

  public static macro function sheet(rules:haxe.macro.Expr.ExprOf<Dynamic>) {
    return pilot.macro.StyleBuilder.createSheet(rules);
  }

  @:from public inline static function ofArray(styles):Style {
    return compose(styles);
  }

  public inline static function compose(styles:Array<Null<Style>>):Style {
    return styles.fold((value:Style, next:Style) -> next.add(value), new Style(''));
  }

  @:deprecated('Use `pilot.VNodeTools.addStyle` instead')
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
      case [ a, b ] if (a.length == 0): b;
      case [ a, b ] if (b.length == 0): a;
      case [ a, b ] if (!a.split(' ').has(b)): '$a $b';
      default: this;
    });
  }

}
