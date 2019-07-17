package pilot;

using StringTools;

abstract Style(String) to String {

  @:from public inline static function ofArray(styles:Array<Style>):Style {
    return compose(styles);
  }

  public static macro function global(rules) {
    pilot.macro.StyleBuilder.create(rules, true);
    return macro null;
  }
  
  public static macro function create(rules) {
    var name = pilot.macro.StyleBuilder.create(rules);
    return macro @:pos(rules.pos) new pilot.Style(${name});
  }

  public inline static function compose(styles:Array<Style>):Style {
    var name = styles
      .filter((s:String) -> s != null && s != '')
      .join(' ');
    
    return name == '' ? null : new Style(name);
  }

  public inline function new(name:String) {
    this = name;
  }

  public inline function add(style:Style) {
    return new Style(switch [ this, (style:String) ] {
      case [ null, v ] | [ v, null ]: v;
      case [ a, b ]: '$a $b';
    });
  }

}
