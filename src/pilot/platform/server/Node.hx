package pilot.platform.server;

using Lambda;
using StringTools;

typedef Attribute = {
  key:String,
  ?value:String
};

class Node {
  
  static final VOID_ELEMENTS = [
    'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 
    'input', 'keygen', 'link', 'meta', 'param', 'source', 
    'track', 'wbr',
  ];

  final tag:String;
  final attributes:Array<Attribute> = [];
  public var textContent:String;
  public var parentNode:Node;
  public var childNodes:Array<Node> = [];
  public var innerHTML:String;
  public var outerHTML(get, null):String;
  function get_outerHTML() return toString();

  public function new(tag) {
    this.tag = tag;
  }
  
  public function getAttribute(key:String):String {
    var attr = findAttribute(key);
    if (attr != null) return attr.value;
    return null;
  }

  public function setAttribute(key:String, value:String) {
    var attr = findAttribute(key);
    if (attr == null) {
      attr = { key: key };
      attributes.push(attr);
    }
    attr.value = value;
  }

  public function removeAttribute(key:String) {
    var attr = findAttribute(key);
    if (attr != null) attributes.remove(attr);
  }

  function findAttribute(key:String):Attribute {
    return attributes.find(a -> a.key == key);
  }

  public function appendChild(child:Node) {
    insertBefore(child);
    return child;
  }

  public function insertBefore(child:Node, ?ref:Node) {
    child.remove();
    child.parentNode = this;
    if (ref != null) {
      // todo: throw error if childNodes does not contain ref?
      childNodes.insert(childNodes.indexOf(ref), child);
      return child;
    }
    childNodes.push(child);
    return child;
  }

  public function replaceChild(child:Node, ref:Node) {
    if (ref.parentNode == this) {
      insertBefore(child, ref);
      removeChild(ref);
      return ref;
    }
    return null;
  }

  public function removeChild(child:Node) {
    childNodes.remove(child);
  }

  public function remove() {
    if (parentNode != null) {
      parentNode.removeChild(this);
    }
  }

  public function nextSibling() {
    if (parentNode != null) {
      return parentNode.childNodes[parentNode.childNodes.indexOf(this) + 1];
    }
    return null;
  }

  public function previousSibling() {
    if (parentNode != null) {
      return parentNode.childNodes[parentNode.childNodes.indexOf(this) - 1];
    }
    return null;
  }

  public function toString() {
    if (tag == '#document') {
      return [ for (c in childNodes) c.toString() ].join('');
    }

    if (tag == '#text') {
      return textContent == null ? '' : textContent.htmlEscape();
    }

    var name = tag.toLowerCase();
    var out = '<${name}';
    var attrs = [ for (attr in attributes) '${attr.key}="${Std.string(attr.value).htmlEscape()}"' ];
    if (attrs.length > 0) {
      out += ' ${attrs.join(' ')}';
    }
    return if (innerHTML != null)
      out + '>' + innerHTML + '</${name}>';
    else if (childNodes.length > 0)
      out + '>' + [ for (c in childNodes) c.toString() ].join('') + '</${name}>';
    else if (VOID_ELEMENTS.has(name))
      out + '/>';
    else
      out + '></${name}>';
  }

}
