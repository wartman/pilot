package pilot.platform.server;

class Server {
  
  public static function createContext() {
    return new Context(new ServerEngine());
  }

  public static function mount(node:Node, vNode:VNode):Root<Node> {
    var root = new Root(node, createContext());
    root.update(vNode);
    return root;
  }

  public static function createRootNode(id:String) {
    var node = new Node('div');
    node.setAttribute('id', id);
    return node;
  }

  public static function renderDocument(
    ?meta:VNode,
    content:VNode
  ) {
    var document = new Node('html');
    var head = new Node('head');
    var body = new Node('body');

    document.appendChild(head);
    document.appendChild(body);

    if (meta != null) mount(head, meta); 
    mount(body, content);

    return '<!doctype html>' + document.toString();
  }

}
