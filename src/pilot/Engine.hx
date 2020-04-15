package pilot;

interface Engine<Node> {
  public final differ:Differ<Node>;
  public function createNode(tag:String):Node;
  public function createSvgNode(tag:String):Node;
  public function createTextNode(content:String):Node;
  public function updateNodeAttr(node:Node, name:String, oldValue:Dynamic, newValue:Dynamic):Void;
  public function updateTextNode(node:Node, content:String):Void;
  public function nodeToString(node:Node):String;
  public function dangerouslySetInnerHtml(node:Node, html:String):Void;
  public function traverseSiblings(first:Node):Cursor<Node>;
  public function traverseChildren(parent:Node):Cursor<Node>;
  public function placeholder(target:Component):VNode;
}
