package pilot;

#if (js && !nodejs)

import js.html.CSSStyleSheet;
import haxe.ds.Map;

class StyleManager {

  static var indices:Map<String, Int>;
  static var defined:Map<String, Bool>;
  static var mounted:Bool = false;
  static var sheet:CSSStyleSheet;

  public static function isDefined(id:String) {
    return defined[id] == true;
  }

  public static function define(id:String, css:()->String):Style {
    if (defined == null) {
      defined = new Map();
    }
    if (!defined[id]) {
      add(id, css());
      defined[id] = true;
    }
    return new Style(id);
  }

  public static function add(id:String, css:String) {
    if (!mounted) mount();
    if (indices == null) {
      indices = new Map();
    }
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

class StyleManager {

  static var rules:Map<String, String>;

  public static function define(id:String, css:()->String):Style {
    if (rules == null) {
      rules = new Map();
    }
    rules.set(id, css());
    return new Style(id);
  }

  public static function toString() {
    return [ for (_ => v in rules) v ].join('\n');
  }

}

#end
