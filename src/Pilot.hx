import pilot.Root;
import pilot.VNode;
import pilot.dom.*;

final class Pilot {
  
  public static final document:Document = Document.root;

  macro public static function html(expr, ?options) {
    return pilot.Html.create(expr, options);
  }

  macro public static function css(expr, ?options) {
    return pilot.Style.create(expr, options);
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
