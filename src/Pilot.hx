import pilot.Root;
import pilot.RealNode;
import pilot.core.VNode;

class Pilot {
  
  macro public static function html(expr) {
    return pilot.dsl.Markup.parse(expr);
  }

  static final rootNodes:Map<RealNode, Root> = [];

  inline public static function mount(node:RealNode, vNode:VNode<RealNode>) {
    if (!rootNodes.exists(node)) {
      rootNodes.set(node, new Root(node));
    }
    rootNodes.get(node).update(vNode);
  }

}
