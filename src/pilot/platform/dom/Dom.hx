package pilot.platform.dom;

import js.html.Node;

class Dom {
  
  public static function createContext() {
    return new Context(new DomEngine());
  }

  public static function mount(node:Node, vNode:VNode):Root<Node> {
    var root = new Root(node, createContext());
    root.replace(vNode);
    return root;
  }

  // todo: hydrate?

}
