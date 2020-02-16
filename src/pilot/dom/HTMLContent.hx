package pilot.dom;

#if (!(js && !nodejs))

/**
  This is a simple hack to allow `innerHTML` to work on server-side elements.
  
  @see pilot.dom.Element#innerHTML
**/
class HTMLContent extends Node {

  final html:String;

  public function new(html) {
    super(DOCUMENT_FRAGMENT_NODE, '#document-fragment');
    this.html = html;
  }

  override function toString():String {
    return html;
  }

}

#end
