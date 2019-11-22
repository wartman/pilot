package pilot;

class Dom {

  inline public static function getElementById(id:String):Node {
    #if (js && !nodejs)
      return js.Browser.document.getElementById(id);
    #else
      var node = new Node('div');
      node.setAttribute('id', id);
      return node;
    #end
  }

  // more?

}
