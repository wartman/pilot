package pilot;

class Dom {

  inline public static final SVG_NS = 'http://www.w3.org/2000/svg';

  inline public static function createFragment() {
    #if (js && !nodejs)
      return js.Browser.document.createDocumentFragment();
    #else
      return new pilot.sys.Node(pilot.sys.Node.FRAGMENT);
    #end
  }
  
  inline public static function createNode(name:String):RealNode {
    #if (js && !nodejs)
      return js.Browser.document.createElement(name);
    #else
      return new pilot.sys.Node(name);
    #end
  }

  inline public static function createSvgNode(name:String):RealNode {
    #if (js && !nodejs)
      return js.Browser.document.createElementNS(SVG_NS, name);
    #else
      return new pilot.sys.Node(name);
    #end
  }

  inline public static function createTextNode(content:String):RealNode {
    #if (js && !nodejs)
      return js.Browser.document.createTextNode(content);
    #else
      var node = new pilot.sys.Node(pilot.sys.Node.TEXT);
      node.textContent = content;
      return node;
    #end
  }

  inline public static function createComment(?comment:String):RealNode {
    #if (js && !nodejs)
      return js.Browser.document.createComment(comment);
    #else
      var node = new pilot.sys.Node(pilot.sys.Node.COMMENT);
      node.textContent = comment;
      return node;
    #end
  }

  inline public static function getElementById(id:String) {
    #if (js && !nodejs)
      return js.Browser.document.getElementById(id);
    #else
      var node = new pilot.sys.Node('div');
      node.setAttribute('id', id);
      return node;
    #end
  }

}
