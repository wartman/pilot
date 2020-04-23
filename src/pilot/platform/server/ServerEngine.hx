package pilot.platform.server;

class ServerEngine implements Engine<Node> {
  
  public final differ:Differ<Node>;

  public function new() {
    differ = new Differ(this);
  }

  public function createNode(tag:String):Node {
    return new Node(tag);
  }

  public function createSvgNode(tag:String):Node {
    // todo: do we need to handle SVGs in a special way?
    return new Node(tag);
  }

  public function updateNodeAttr(
    node:Node,
    key:String,
    oldValue:Dynamic,
    newValue:Dynamic
  ):Void {
    if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
      // noop
    } else if (key == 'className') {
      node.setAttribute('class', newValue);
    } else if (newValue == null || newValue == false) {
      node.removeAttribute(key);
    } else if (newValue == true) {
      node.setAttribute(key, key);
    } else {
      node.setAttribute(key, newValue);
    }
  }

  public function createTextNode(content:String):Node {
    var n = new Node('#text');
    n.textContent = content;
    return n;
  }

  public function createCommentNode(content:String):Node {
    var n = new Node('#comment');
    n.textContent = content;
    return n;
  }

  public function updateTextNode(node:Node, content:String):Void {
    node.textContent = content;
  }

  public function getTextNodeContent(node:Node):String {
    return node.textContent;
  }

  public function nodeToString(node:Node):String {
    return node.outerHTML;
  }

  public function dangerouslySetInnerHtml(node:Node, html:String):Void {
    node.innerHTML = html;
  }

  public function traverseSiblings(first:Node):Cursor<Node> {
    return new ServerCursor(first.parentNode, first);
  }

  public function traverseChildren(parent:Node):Cursor<Node> {
    return new ServerCursor(parent, parent.childNodes[0]);
  }

  public function placeholder(target:Component):VNode {
    return VNative(TextType, { content: '' }, [], null, null, null, true);
  }

}
