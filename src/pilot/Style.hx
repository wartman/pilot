package pilot;

using StringTools;

abstract Style(String) to String {

  public static macro function global(rules) {
    pilot.macro.StyleBuilder.create(rules, true);
    return macro null;
  }
  
  public static macro function create(rules) {
    var name = pilot.macro.StyleBuilder.create(rules);
    return macro @:pos(rules.pos) new pilot.Style(${name});
  }

  public static function compose(classes:Array<Style>) {
    return switch classes
      .filter(s -> s != null)
      .map(c -> c.trim())
      .filter(c -> c != null && c != '')
      .join(' ') {
      case '': null;
      case c: c;
    }
  }

  public inline function new(name:String) {
    this = name;
  }

}
