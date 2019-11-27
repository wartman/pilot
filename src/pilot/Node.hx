package pilot;

#if (js && !nodejs)
  import js.Browser;
#else
  import haxe.DynamicAccess;

  using StringTools;
#end

enum NodeKind {
  Native;
  Svg;
  Fragment;
  Text;
}

#if (js && !nodejs)

@:forward
abstract Node(js.html.Node) from js.html.Node to js.html.Node {
  
  inline public static final SVG_NS = 'http://www.w3.org/2000/svg';

  public var outerHTML(get, never):String;
  inline function get_outerHTML():String {
    return toElement().outerHTML;
  }

  public var innerHTML(get, never):String;
  inline function get_innerHTML():String {
    return toElement().innerHTML;
  }
  
  public function new(name:String, kind:NodeKind = Native) {
    this = switch kind {
      case Native: Browser.document.createElement(name);
      case Svg: Browser.document.createElementNS(SVG_NS, name);
      case Fragment: Browser.document.createDocumentFragment();
      case Text: Browser.document.createTextNode(name);
    }
  }

  inline public function setAttribute(key:String, value:Dynamic) {
    toElement().setAttribute(key, value);
  }

  inline public function removeAttribute(key:String) {
    toElement().removeAttribute(key);
  }

  inline public function toElement():js.html.Element {
    return cast this;
  }

}

#else

class Node {
    
  public final nodeName:String;
  public final childNodes:Array<Node> = [];
  public var textContent:String;
  public var parentNode:Node;
  final kind:NodeKind;
  var attributes:DynamicAccess<Dynamic> = {};

  public var outerHTML(get, never):String;
  inline function get_outerHTML():String {
    return toString();
  }

  public var innerHTML(get, never):String;
  inline function get_innerHTML():String {
    return [ for (c in childNodes) c.toString() ].join('');
  }
  
  public function new(nodeName, kind = Native) {
    this.kind = kind;
    switch kind {
      case Text:
        this.nodeName = 'TEXT';
        textContent = nodeName; 
      default:
        this.nodeName = nodeName;
    }
  }

  public function setAttribute(key:String, value:Dynamic) {
    attributes[key] = value;
  }

  public function removeAttribute(key:String) {
    attributes.remove(key);
  }

  public function appendChild(child:Node) {
    if (child.parentNode != null) {
      throw 'Node already has a parent';
    }
    child.parentNode = this;
    childNodes.push(child);
  }

  public function removeChild(child:Node) {
    childNodes.remove(child);
    child.parentNode = null;
    return child;
  }

  public function remove() {
    if (parentNode != null) {
      parentNode.childNodes.remove(this);
    }
    parentNode = null;
  }

  public function insertBefore(newNode:Node, ?referenceNode:Node) {
    if (referenceNode == null) {
      appendChild(newNode);
    } else {
      childNodes.insert(childNodes.indexOf(referenceNode), newNode);
    }
  }

  public function toString() {
    return switch kind {
      case Text: 
        textContent;
      case Fragment: 
        [ for (c in childNodes) c.toString() ].join('');
      default: 
        var out = '<${nodeName}';
        var attrs = [ for (key => value in attributes) '${key} = "${Std.string(value).htmlEscape()}"' ];
        if (attrs.length > 0) {
          out += ' ${attrs.join(' ')}';
        }
        if (childNodes.length > 0) 
          out + '>' + [ for (c in childNodes) c.toString() ].join('') + '</${nodeName}>';
        else
          out + '/>';
    }
  }

}

#end
