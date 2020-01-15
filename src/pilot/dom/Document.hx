package pilot.dom;

#if (js && !nodejs)

@:forward
abstract Document(js.html.Document) from js.html.Document to js.html.Document {
  
  static public final root:Document = js.Browser.document;

}

#else

class Document extends Element {

  static public final root = new Document();
  
  public final documentElement:Node = new Element(ELEMENT_NODE, 'html');
  public final body:Node = new Element(ELEMENT_NODE, 'body');
  public final head:Node = new Element(ELEMENT_NODE, 'head');

  public function new() {
    super(DOCUMENT_NODE, '#document');
    appendChild(documentElement);
    documentElement.appendChild(body);
    documentElement.appendChild(head);
  }

  public function createElement(tag:String) {
    return new Element(ELEMENT_NODE, tag.toUpperCase());
  }

  public function createElementNS(ns:String, tag:String) {
    var el = createElement(tag);
    el.namespace = ns;
    return el;
  }

  public function createTextNode(text:String) {
    return new Text(text);
  }

}

#end
