package pilot.html;

#if (js && !nodejs)

@:forward
abstract Document(js.html.Document) from js.html.Document to js.html.Document {
  
  static public final root:Document = js.Browser.document;

}

#else

class Document extends Element {

  static public final root = new Document();
  
  public final body:Node = new Element(ELEMENT_NODE, 'body');
  public final html:Node = new Element(ELEMENT_NODE, 'html');

  public function new() {
    super(DOCUMENT_NODE, '#document');
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
