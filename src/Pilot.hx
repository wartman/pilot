import pilot.Root;
import pilot.Node;
import pilot.VNode;
import pilot.Dom;

final class Pilot {

  public static final dom = Dom;
  
  macro public static function html(expr) {
    return pilot.dsl.Markup.parse(expr);
  }

  macro public static function css(expr) {
    return pilot.dsl.Css.parse(expr);
  }

  macro public static function globalCss(expr) {
    return pilot.dsl.Css.parse(expr, false, true);
  }

  #if (js && !nodejs)
    
    macro public static function embedCss(expr) {
      return pilot.dsl.Css.parse(expr, true);
    }

    macro public static function embedGlobalCss(expr) {
      return pilot.dsl.Css.parse(expr, true, true);
    }

  #end

  static final rootNodes:Map<Node, Root> = [];

  /**
    Mount vNodes on the real dom. If no `pilot.Node` is provided, will default
    to the document body.
  **/
  inline public static function mount(?node:Node, vNode:VNode):Root {
    if (node == null) {
      node = Dom.getBody();
    }
    if (!rootNodes.exists(node)) {
      rootNodes.set(node, new Root(node));
    }
    var root = rootNodes.get(node);
    root.update(vNode);
    return root;
  }

}
