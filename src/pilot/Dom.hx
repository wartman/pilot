package pilot;

class Dom {
  
  inline public static function createNode(name:String):RealNode {
    #if js
      return js.Browser.document.createElement(name);
    #else
      return new pilot.sys.Node(name);
    #end
  }

  inline public static function createTextNode(content:String):RealNode {
    #if js
      return js.Browser.document.createTextNode(content);
    #else
      var node = new pilot.sys.Node(pilot.sys.Node.TEXT);
      node.textContent = content;
      return node;
    #end
  }

  inline public static function getElementById(id:String) {
    #if js
      return js.Browser.document.getElementById(id);
    #else
      var node = new pilot.sys.Node('div');
      node.setAttribute('id', id);
      return node;
    #end
  }

}
