package pilot;

using StringTools;
using Lambda;

abstract Style(String) to String {
  
  public static macro function create(rules:haxe.macro.Expr.ExprOf<Dynamic>) {
    return pilot.macro.StyleBuilder.create(rules);
  }
  
  public static macro function global(rules) {
    return pilot.macro.StyleBuilder.create(rules, true);
  }

  @:deprecated('Just use Style.sheet now')
  public static macro function sheet(rules:haxe.macro.Expr.ExprOf<Dynamic>) {
    return pilot.macro.StyleBuilder.createSheet(rules);
  }

  @:from public inline static function ofArray(styles:Array<Style>):Style {
    return compose(styles);
  }

  @:from public static inline function ofStyleSheet(sheet:StyleSheet):Style {
    return sheet.all();
  }

  public inline static function compose(styles:Array<Style>):Style {
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
      case [ a, b ] if (!a.split(' ').has(b)): '$a $b';
      default: this;
    });
  }

}
