package pilot;

class Dom {

  inline public static function getBody():Node {
    #if (js && !nodejs)
      return js.Browser.document.body;
    #else
      return new Node('body');
    #end
  }

  inline public static function getHead():Node {
    #if (js && !nodejs)
      return js.Browser.document.head;
    #else
      return new Node('head');
    #end
  }

  inline public static function getElementById(id:String):Node {
    #if (js && !nodejs)
      return js.Browser.document.getElementById(id);
    #else
      var node = new Node('div');
      node.setAttribute('id', id);
      return node;
    #end
  }

  inline public static function createNode(tag:String) {
    return new Node(tag, Native);
  }

  inline public static function createSvgNode(tag:String) {
    return new Node(tag, Svg);
  }

  inline public static function createTextNode(content:String) {
    return new Node(content, Text);
  }

  // more? Maybe a simple `querySelector` function? Might use the Selector
  // parser from the Css dsl, hm.

}
