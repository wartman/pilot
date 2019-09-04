package pilot;

#if (js && !nodejs)

import js.html.CSSStyleSheet;
import haxe.ds.Map;

class StyleManager {

  static final indices:Map<String, Int> = new Map();
  static final defined:Map<String, Bool> = new Map();
  static var mounted:Bool = false;
  static var sheet:CSSStyleSheet;

  public static function isDefined(id:String) {
    return defined[id] == true;
  }

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
