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

  static final rootNodes:Map<Node, Root> = [];

  inline public static function mount(node:Node, vNode:VNode) {
    if (!rootNodes.exists(node)) {
      rootNodes.set(node, new Root(node));
    }
    rootNodes.get(node).update(vNode);
  }

}
