package pilot.html;

#if (js && !nodejs)

typedef Text = js.html.Text;

#else

using StringTools;

class Text extends Node {
  
  public var nodeValue:String;

  public function new(content:String) {
    super(TEXT_NODE, '#text');
    nodeValue = content;
  }

  public var textContent(get, set):String;
  function get_textContent() return nodeValue;
  function set_textContent(textContent:String) return nodeValue = textContent;

  override function toString() {
    return nodeValue.htmlEscape();
  }

}

#end
