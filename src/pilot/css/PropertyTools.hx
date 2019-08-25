package pilot.css;

class PropertyTools {

  static final ucase:EReg = ~/[A-Z]/g;
  public static function toKebabCase(s:String):String {
    return [ for (i in 0...s.length)
      if (ucase.match(s.charAt(i))) {
        '-' + s.charAt(i).toLowerCase();
      } else {
        s.charAt(i);
      } 
    ].join('');
  }

}
