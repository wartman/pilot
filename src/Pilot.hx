class Pilot {
  
  macro public static function html(expr, ?options) {
    return pilot.Html.create(expr, options);
  }

  macro public static function css(expr, ?options) {
    return pilot.Style.create(expr, options);
  }

  #if (js && !nodejs)
    public static function mount(
      node:js.html.Node,
      vNode:pilot.VNode
    ):pilot.Root<js.html.Node> {
      var root = new pilot.Root(
        node, 
        new pilot.Context(new pilot.platform.dom.DomEngine())
      );
      root.update(vNode);
      return root;
    }
  #else
    public static function mount(
      node:pilot.platform.server.Node, 
      vNode:pilot.VNode
    ):pilot.Root<pilot.platform.server.Node> {
      var root = new pilot.Root(
        node, 
        new pilot.Context(new pilot.platform.server.ServerEngine())
      );
      root.update(vNode);
      return root;
    }
  #end

}
