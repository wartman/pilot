package pilot;

#if (js && !nodejs)

import js.html.CSSStyleSheet;
import haxe.ds.Map;

// using StringTools;

class StyleManager {

  // static final nameRe = ~/[^a-z0-9]/g;

  // public static function makeClassNameSafe(name:String):String {
  //   return nameRe.map(name, reg -> {
  //     var match = reg.matched(0);
  //     var c = match.charCodeAt(0);
  //     if (c == 32) return '_';
  //     if (c >= 65 && c <= 90) return '_' + match.toLowerCase();
  //     return '__' + ('000' + c.hex(16)).substr(-4);
  //   });
  // }

  static final indices:Map<String, Int> = new Map();
  static final defined:Map<String, Bool> = new Map();
  static var mounted:Bool = false;
  static var sheet:CSSStyleSheet;

  public static function define(id:String, css:()->String):Style {
    if (!defined[id]) {
      add(id, css());
      defined[id] = true;
    }
    return new Style(id);
  }

  public static function add(id:String, css:String) {
    if (!mounted) mount();
    sheet.insertRule(
      '@media all { ${css} }',
      switch indices[id] {
        case null: indices[id] = sheet.cssRules.length;
        case v: v;
      }
    );
  }

  static function mount() {
    if (mounted) return;
    mounted = true;
    var styleEl = js.Browser.document.createStyleElement();
    js.Browser.document.head.appendChild(styleEl);
    sheet = cast styleEl.sheet;
  }
  
}

#else

class StyleManager {}

#end
