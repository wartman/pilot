package pilot;

using Lambda;

abstract Style(String) to String {

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
