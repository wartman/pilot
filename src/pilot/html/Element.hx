package pilot.html;

#if (js && !nodejs)

typedef Element = js.html.Element;

#else

using Lambda;
using StringTools;

typedef Attribute = {
  ?ns:String,
  key:String,
  ?value:String
};

class Element extends Node {

  final attributes:Array<Attribute> = [];
  final style:Dynamic = {};
  public var namespace:String;

  public function new(nodeType, nodeName:String) {
    super(nodeType, nodeName);
  }

  public var className(get, set):String;
  function get_className():String return getAttribute('class');
  function set_className(className:String):String {
    setAttribute('class', className);
    return className;
  }

  public var cssText(get, set):String;
  function get_cssText():String return getAttribute('style');
  function set_cssText(cssText:String):String {
    setAttribute('style', cssText);
    return cssText;
  }

  public var outerHTML(get, never):String;
  inline function get_outerHTML():String {
    return toString();
  }

  public var innerHTML(get, never):String;
  inline function get_innerHTML():String {
    return [ for (c in childNodes) c.toString() ].join('');
  }

  public function getAttribute(key:String) {
    return getAttributeNS(null, key);
  }

  public function setAttribute(key:String, value:String) {
    setAttributeNS(null, key, value);
  }

  public function removeAttribute(key:String) {
    removeAttributeNS(null, key);
  }

  public function getAttributeNS(ns:String, key:String):String {
    var attr = findAttribute(ns, key);
    if (attr != null) return attr.value;
    return null;
  }

  public function setAttributeNS(ns:String, key:String, value:String) {
    var attr = findAttribute(ns, key);
    if (attr == null) {
      attr = { ns: ns, key: key };
      attributes.push(attr);
    }
    attr.value = value;
  }

  public function removeAttributeNS(ns:String, key:String) {
    var attr = findAttribute(ns, key);
    if (attr != null) attributes.remove(attr);
  }

  function findAttribute(ns:String, key:String):Attribute {
    return attributes.find(a -> a.ns == ns && a.key == key);
  }

  // maybe
  public function getElementById(id:String) {
    return childNodes.find(n -> switch Std.downcast(n, Element) {
      case null: false;
      case el: el.getAttribute('id') == id;
    });
  }

  override function toString() {
    if (nodeType == DOCUMENT_NODE) {
      return [ for (c in childNodes) c.toString() ].join('');
    }
    var out = '<${nodeName}';
    var attrs = [ for (attr in attributes) '${attr.key} = "${Std.string(attr.value).htmlEscape()}"' ];
    if (attrs.length > 0) {
      out += ' ${attrs.join(' ')}';
    }
    return if (childNodes.length > 0) 
      out + '>' + [ for (c in childNodes) c.toString() ].join('') + '</${nodeName}>';
    else
      out + '/>';
  }

}

#end
