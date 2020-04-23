package pilot.platform.dom;

import js.Browser;
import js.html.Node;
import js.html.Text;
import js.html.Element;

class DomEngine implements Engine<Node> {

  inline public static final SVG_NS = 'http://www.w3.org/2000/svg';

  public final differ:Differ<Node>;

  public function new() {
    differ = new Differ(this);
  }

  public function createNode(tag:String):Node {
    return Browser.document.createElement(tag);
  }

  public function createSvgNode(tag:String):Node {
    return Browser.document.createElementNS(SVG_NS, tag);
  }

  public function updateNodeAttr(
    node:Node,
    key:String,
    oldValue:Dynamic,
    newValue:Dynamic
  ):Void {
    var el:Element = cast node;
    var isSvg = el.namespaceURI == SVG_NS;
    switch key {
      case 'xmlns' if (isSvg): // skip
      case 'innerHTML':
        throw 'Don\'t use `innerHTML` -- use `@dangerouslySetInnerHtml` instead';
      case 'value' | 'selected' | 'checked' if (!isSvg):
        js.Syntax.code('{0}[{1}] = {2}', el, key, newValue);
      case _ if (!isSvg && js.Syntax.code('{0} in {1}', key, el)):
        js.Syntax.code('{0}[{1}] = {2}', el, key, newValue);
      default: 
        if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
          var ev = key.substr(2).toLowerCase();
          el.removeEventListener(ev, oldValue);
          if (newValue != null) el.addEventListener(ev, newValue);
        } else if (newValue == null || (Std.is(newValue, Bool) && newValue == false)) {
          el.removeAttribute(key);
        } else if (Std.is(newValue, Bool) && newValue == true) {
          el.setAttribute(key, key);
        } else {
          el.setAttribute(key, newValue);
        }
    }
  }

  public function createTextNode(content:String):Node {
    return Browser.document.createTextNode(content);
  }

  public function createCommentNode(content:String):Node {
    return Browser.document.createComment(content);
  }

  public function updateTextNode(node:Node, content:String):Void {
    switch Std.downcast(node, Text) {
      case null: throw 'assert';
      case text: text.textContent = content;
    }
  }

  public function getTextNodeContent(node:Node):String {
    return switch Std.downcast(node, Text) {
      case null: '';
      case text: text.textContent;
    }
  }

  public function nodeToString(node:Node):String {
    return switch Std.downcast(node, Text) {
      case null: switch Std.downcast(node, Element) {
        case null: return '[${node.nodeName}]';
        case el: el.outerHTML;
      }
      case text: text.textContent;
    }
  }

  public function dangerouslySetInnerHtml(node:Node, html:String):Void {
    switch Std.downcast(node, Element) {
      case null:
        throw 'Invalid target for @dangerouslySetInnerHtml: should be an Element';
      case el:
        el.innerHTML = html;
    } 
  }

  public function traverseSiblings(first:Node):Cursor<Node> {
    return new DomCursor(first.parentNode, first);
  }

  public function traverseChildren(parent:Node):Cursor<Node> {
    return new DomCursor(parent, parent.firstChild);
  }

  public function placeholder(target:Component):VNode {
    return VNative(TextType, { content: '' }, [], null, null, null, true);
  }

}
