package pilot.platform.dom;

import js.html.Node;

class Dom {
  
  inline public static function createContext() {
    return new Context(new DomEngine());
  }

  public static function mount(node:Node, vNode:VNode):Root<Node> {
    var root = new Root(node, createContext());
    root.replace(vNode);
    return root;
  }

  public static function hydrate(node:Node, vNode:VNode):Root<Node> {
    var root = new Root(node, createContext());
    root.hydrate(vNode);
    return root;
  }

}
