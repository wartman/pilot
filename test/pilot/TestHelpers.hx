package pilot;

class TestHelpers {

  public static function createContext() {
    #if (js && !nodejs)
      return new Context(new pilot.platform.dom.DomEngine());
    #else
      return new Context(new pilot.platform.server.ServerEngine());
    #end
  }

  public static function render(vn:VNode) {
    var context = createContext();
    var root = new Root(context.engine.createNode('div'), context);
    root.update(vn);
    return root;
  }

  public static function later(cb:()->Void) {
    Helpers.later(cb);
  }

}
