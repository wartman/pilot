import pilot.Root;
import pilot.VNode;
import pilot.dom.*;

final class Pilot {
  
  public static final document:Document = Document.root;

  macro public static function html(expr) {
    return pilot.dsl.Markup.parse(expr);
  }

  macro public static function css(expr) {
    return pilot.dsl.Css.parse(expr);
  }

  macro public static function globalCss(expr) {
    return pilot.dsl.Css.parse(expr, false, true);
  }
    
  macro public static function embedCss(expr) {
    return pilot.dsl.Css.parse(expr, true);
  }

  macro public static function embedGlobalCss(expr) {
    return pilot.dsl.Css.parse(expr, true, true);
  }

  static final rootNodes:Map<Element, Root> = [];

  inline public static function mount(el:Element, vNode:VNode):Root {
    if (!rootNodes.exists(el)) {
      rootNodes.set(el, new Root(el));
    }
    var root = rootNodes.get(el);
    root.update(vNode);
    return root;
  }

}
