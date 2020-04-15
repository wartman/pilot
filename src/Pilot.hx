class Pilot {
  
  macro public static function html(expr, ?options) {
    return pilot.Html.create(expr, options);
  }

  macro public static function css(expr, ?options) {
    return pilot.Style.create(expr, options);
  }

  public static function mount(node, vNode) {
    #if (js && !nodejs)
      return pilot.platform.dom.Dom.mount(node, vNode);
    #else
      return pilot.platform.server.Server.mount(node, vNode);
    #end
  }

}
