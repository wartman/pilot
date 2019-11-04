package pilot.sys;

import haxe.DynamicAccess;

using StringTools;

class Node {

  public static final TEXT = '__text__';
  
  public final nodeName:String;
  public final childNodes:Array<Node> = [];
  public var textContent:String;
  public var parentNode:Node;
  var attributes:DynamicAccess<Dynamic> = {};

  public function new(nodeName) {
    this.nodeName = nodeName;
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
    if (nodeName == TEXT) return textContent;

    var out = '<${nodeName}';
    var attrs = [ for (key => value in attributes) '${key} = "${Std.string(value).htmlEscape()}"' ];
    if (attrs.length > 0) {
      out += ' ${attrs.join(' ')}';
    }
    return if (childNodes.length > 0) 
      out + '>' + [ for (c in childNodes) c.toString() ].join('') + '</${nodeName}>';
    else
      out + '/>';
  }

}
