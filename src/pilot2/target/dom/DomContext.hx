package pilot2.target.dom;

import js.html.Node;
import pilot2.diff.*;

class DomContext implements Context<Node> {
  
  public function new() {}

  public function setPreviousRender(node:Node, render:RenderResult<Node>) {
    untyped node._pilot_result = render;
  }

  public function getPreviousRender(node:Node):RenderResult<Node> {
    var res:RenderResult<Node> = untyped node._pilot_result;
    if (res == null) {
      res = recycleNode(node);
      setPreviousRender(node, res);
    }
    return res;
  }

  public function removePreviousRender(node:Node, recursive:Bool = false) {
    if (recursive) for (n in node.childNodes) removePreviousRender(n, true);
    var res:RenderResult<Node> = untyped node._pilot_result;
    if (res != null) res.dispose();
    js.Syntax.code('delete {0}._pilot_result', node);
  }

  public function getChildren(node:Node):Array<Node> {
    return [ for (n in node.childNodes) n ];
  }

  public function addChild(node:Node, child:Node):Void {
    node.appendChild(child);
  }

  public function removeChild(node:Node, child:Node):Void {
    node.removeChild(child);
  }

  public function insertBefore(parent:Node, target:Node, node:Node):Void {
    parent.insertBefore(target, node);
  }

  function recycleNode(node:Node):RenderResult<Node> {
    var res = new RenderResult(
      RNative(node, {}), 
      [], 
      []
    );
    for (n in node.childNodes) {
      res.add(DomFactory.getNodeType(n.nodeName), RNative(n, {}));
    }
    return res;
  }

}
