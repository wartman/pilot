package pilot;

import haxe.DynamicAccess;
import js.Browser;
import js.html.Node;
import js.html.Element;
import pilot.VNode;

using StringTools;
using Reflect;

/**
  This is a haxe port of https://github.com/jorgebucaran/superfine
**/
class Differ {

  public static function patch(node:Node, vnode:VNode) {
    node = patchNode(
      node,
      node,
      node.field('__vnode') != null 
        ? node.field('__vnode')
        : recycleNode(node),
      vnode,
      false
    );
    node.setField('__vnode', vnode);
    return vnode;
  }

  static function patchNode(
    parent:Node,
    node:Node,
    oldVNode:VNode,
    newVNode:VNode,
    isSvg:Bool
  ) {
    if (oldVNode == newVNode) {
    } else if (
      oldVNode != null
      && oldVNode.type == VNodeText
      && newVNode.type == VNodeText
    ) {
      if (oldVNode.name != newVNode.name) {
        node.nodeValue = newVNode.name;
      }
    } else if (oldVNode == null || oldVNode.name != newVNode.name) {
      node = parent.insertBefore(createNode(newVNode, isSvg), node);
      if (oldVNode != null && oldVNode.node != null) {
        detachNode(parent, oldVNode);
      }
    } else {
      var tmpVChild;
      var oldVChild;

      var oldKey:VNodeKey;
      var newKey:VNodeKey;

      var oldVProps = oldVNode.props;
      var newVProps = newVNode.props;
      var oldVChildren = oldVNode.children;
      var newVChildren = newVNode.children;

      var oldHead = 0;
      var newHead = 0;
      var oldTail = oldVChildren.length - 1;
      var newTail = newVChildren.length - 1;

      isSvg = isSvg || newVNode.name == 'svg';

      for (k => _ in merge(oldVProps, newVProps)) {
        switch k {
          case 'value' | 'selected' | 'checked':
            if (node.field(k) != newVProps.field(k)) {
              patchProperty(
                node,
                k,
                oldVProps.field(k),
                newVProps.field(k), 
                isSvg
              );
            }
          default:
            if (oldVProps.field(k) != newVProps.field(k)) {
              patchProperty(
                node,
                k,
                oldVProps.field(k),
                newVProps.field(k),
                isSvg
              );
            }
        }
      }

      while (newHead <= newTail && oldHead <= oldTail) {
        if (
          (oldKey = getKey(oldVChildren[oldHead])) == null
          || oldKey != getKey(newVChildren[newHead])
        ) {
          break;
        }

        patchNode(
          node,
          oldVChildren[oldHead].node,
          oldVChildren[oldHead++],
          newVChildren[newHead++],
          isSvg
        );        
      }
      
      while (newHead <= newTail && oldHead <= oldTail) {
        if (
          (oldKey = getKey(oldVChildren[oldTail])) == null
          || oldKey != getKey(newVChildren[newTail])
        ) {
          break;
        }

        patchNode(
          node,
          oldVChildren[oldTail].node,
          oldVChildren[oldTail--],
          newVChildren[newTail--],
          isSvg
        );        
      }

      if (oldHead > oldTail) {
        while (newHead <= newTail) {
          node.insertBefore(
            createNode(newVChildren[newHead++], isSvg),
            (oldVChild = oldVChildren[oldHead]) != null 
              ? oldVChild.node 
              : null
          );
        }
      } else if (newHead > newTail) {
        while (oldHead <= oldTail) {
          detachNode(node, oldVChildren[oldHead++]);
        }
      } else {
        var keyed:DynamicAccess<VNode> = {};
        var newKeyed:DynamicAccess<Bool> = {};

        var i = oldHead;
        while (i <= oldTail) {
          if ((oldKey = oldVChildren[i].key) != null) {
            keyed.set(oldKey, oldVChildren[i]);
          }
          i++;
        }

        while (newHead <= newTail) {
          oldKey = getKey((oldVChild = oldVChildren[oldHead]));
          newKey = getKey(newVChildren[newHead]);

          if (
            newKeyed.get(oldKey) != null
            || (newKey != null && newKey == getKey(oldVChildren[oldHead + 1]))
          ) {
            if (oldKey == null) {
              detachNode(node, oldVChild);
            }
            oldHead++;
            continue;
          }

          if (newKey == null || oldVNode.type == VNodeRecycled) {
            if (oldKey == null) {
              patchNode(
                node, 
                oldVChild != null ? oldVChild.node : null,
                oldVChild,
                newVChildren[newHead],
                isSvg
              );
              newHead++;
            }
            oldHead++;
          } else {
            if (oldKey == newKey) {
              patchNode(
                node,
                oldVChild.node,
                oldVChild,
                newVChildren[newHead],
                isSvg
              );
              newKeyed.set(newKey, true);
              oldHead++;
            } else {
              if ((tmpVChild = keyed[newKey]) != null) {
                patchNode(
                  node,
                  node.insertBefore(
                    tmpVChild.node,
                    oldVChild != null ? oldVChild.node : null
                  ),
                  tmpVChild,
                  newVChildren[newHead],
                  isSvg
                );
                newKeyed.set(newKey, true);
              } else {
                patchNode(
                  node,
                  oldVChild != null ? oldVChild.node : null,
                  null,
                  newVChildren[newHead],
                  isSvg
                );
              }
            }
            newHead++;
          }
        }

        while (oldHead <= oldTail) {
          if (getKey((oldVChild = oldVChildren[oldHead++])) == null) {
            detachNode(node, oldVChild);
          }
        }

        for (k => vnode in keyed) {
          if (newKeyed.get(k) == null) {
            detachNode(node, vnode);
          }
        }

      }
    }

    newVNode.node = node;
    return node;
  }

  static function detachNode(parent:Node, vnode:VNode) {
    doDetachHook(vnode);
    parent.removeChild(vnode.node);
  }

  static function doDetachHook(vnode:VNode) {
    if (vnode.hooks.detach != null) {
      vnode.hooks.detach();
    }
  }

  static function doAttachHook(vnode:VNode) {
    if (vnode.hooks.attach != null && vnode.node != null) {
      vnode.hooks.attach(vnode);
    }
  }

  static function getKey(?vnode:VNode) {
    return if (vnode == null) null else vnode.key; 
  }

  static function merge(a:{}, b:{}):DynamicAccess<Dynamic> {
    var out:DynamicAccess<Dynamic> = new DynamicAccess();
    for (k => v in (a:DynamicAccess<Dynamic>)) out.set(k, v);
    for (k => v in (b:DynamicAccess<Dynamic>)) out.set(k, v);
    return out;
  }

  static function recycleNode(node:Node) {
    return node.nodeType == 3
      ? VNode.text(node.nodeValue, node)
      : new VNode({
          name: node.nodeName.toLowerCase(),
          props: {},
          children: [ for (n in node.childNodes) recycleNode(n) ],
          node: node,
          type: VNodeRecycled,
          key: null
        });
  }

  static function createNode(vnode:VNode, isSvg:Bool):Node {
    var node = switch vnode.type {
      case VNodeText:
        Browser.document.createTextNode(vnode.name);
      case VNodeElement if (isSvg || vnode.name == 'svg'):
        Browser.document.createElementNS('"http://www.w3.org/2000/svg', vnode.name);
      case VNodeFragment:
        Browser.document.createDocumentFragment();
      default:
        Browser.document.createElement(vnode.name);
    }

    for (key => value in (vnode.props:DynamicAccess<Dynamic>)) {
      patchProperty(node, key, null, value, isSvg);
    }

    for (child in vnode.children) {
      node.appendChild(createNode(child, isSvg));
    }

    vnode.node = node;
    doAttachHook(vnode);
    return node;
  }

  static function patchProperty(
    node:Node,
    key:String,
    oldValue:Dynamic,
    newValue:Dynamic,
    isSvg:Bool
  ) {
    if (key == 'key') return;
    if (key.startsWith('on')) {
      var event = key.substr(2).toLowerCase();
      node.removeEventListener(event, oldValue);
      if (newValue != null) {
        node.addEventListener(event, newValue);
      }
    } else if (!isSvg && key != 'list' && node.hasField(key)) {
      node.setProperty(key, newValue == null ? '' : newValue );
    } else if (newValue == null || newValue == false) {
      var el:Element = cast node;
      el.removeAttribute(key);
    } else {
      var el:Element = cast node;
      if (key == 'className') key = 'class';
      if (key == 'htmlFor') key = 'for';
      el.setAttribute(key, newValue);
    }
  }

}