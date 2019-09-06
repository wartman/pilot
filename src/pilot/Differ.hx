package pilot;

import haxe.DynamicAccess;
import js.Browser;
import js.html.Node;
import js.html.Element;
import js.html.Event;
import pilot.VNode;

using StringTools;
using Reflect;
using pilot.VNodeTools;

/**
  This is a haxe port of https://github.com/jorgebucaran/superfine
**/
class Differ {

  public static function patch(node:Node, vnode:VNode) {
    node = patchNode(
      node,
      node,
      getNodeVNode(node) != null 
        ? getNodeVNode(node)
        : recycleNode(node),
      vnode,
      vnode.name == 'svg'
    );
    setNodeVNode(node, vnode);
    return vnode;
  }

  /**
    This method will update a VNode rather than returning a new one,
    which is needed for subPatching.
  **/
  public static function subPatch(vnode:VNode, newVNode:VNode) {
    patchNode(
      vnode.node,
      vnode.node,
      vnode,
      newVNode,
      vnode.name == 'svg'
    );
    vnode.name = newVNode.name;
    vnode.key = newVNode.key;
    vnode.style = newVNode.style;
    vnode.props = newVNode.props;
    vnode.children = newVNode.children;
    vnode.type = newVNode.type;
    vnode.hooks = newVNode.hooks;
  }

  public inline static function setNodeVNode(node:Node, vnode:VNode) {
    node.setField('__vnode', vnode);
  }

  public inline static function getNodeVNode(node:Node) {
    return node.field('__vnode');
  }

  static function patchNode(
    parent:Node,
    node:Node,
    oldVNode:VNode,
    newVNode:VNode,
    isSvg:Bool
  ) {

    if (oldVNode != null) {
      newVNode = doWillPatchHook(oldVNode, newVNode);
    }

    applyStyle(newVNode);
    
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

      isSvg =  isSvg || newVNode.name == 'svg';

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
            newKeyed.get(oldKey)
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
              if ((tmpVChild = keyed.get(newKey)) != null) {
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
    if (!parent.contains(vnode.node)) {
      return;
    }
    parent.removeChild(vnode.node);
  }

  static inline function doDetachHook(vnode:VNode) {
    if (vnode.hooks.detach != null) {
      vnode.hooks.detach();
    }
    for (child in vnode.children) {
      doDetachHook(child);
    }
  }

  static inline function doAttachHook(vnode:VNode) {
    if (vnode.hooks.attach != null && vnode.node != null) {
      vnode.hooks.attach(vnode);
    }
  }

  static inline function doWillPatchHook(vnode:VNode, newVNode:VNode) {
    if (vnode.hooks.willPatch != null) {
      return vnode.hooks.willPatch(newVNode);
    }
    return newVNode;
  }

  static function getKey(?vnode:VNode) {
    return if (vnode == null) null else vnode.key; 
  }

  static inline function applyStyle(vnode:VNode) {
    vnode.addClassName(vnode.style);
    vnode.style = null;
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
    if (vnode.name == 'svg') isSvg = true;

    applyStyle(vnode);

    var node = switch vnode.type {
      case VNodeText:
        Browser.document.createTextNode(vnode.name);
      case VNodeFragment:
        Browser.document.createDocumentFragment();
      case VNodeElement if (isSvg):
        Browser.document.createElementNS('http://www.w3.org/2000/svg', vnode.name);
      case VNodeElement | VNodeRecycled:
        Browser.document.createElement(vnode.name);
      case VNodePlaceholder:
        Browser.document.createComment('');
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
      var listener = getListener(node);
      getHandlers(node).setField(event, newValue);
      if (newValue == null) {
        node.removeEventListener(event, listener);
      } else if (oldValue == null) {
        node.addEventListener(event, listener);
      }
    } else if (!isSvg && key != 'list' && node.getProperty(key) != null) {
      // This seems a bit fishy -- we may want to use a method other than
      // `Reflect` :/
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

  static inline function getListener(node:Node) {
    if (node.field('__listener') == null) {
      node.setField('__listener', function (event:Event) {
        var cb:(e:Event)->Void = getHandlers(node).field(event.type);
        if (cb != null) cb(event);
      });
    }
    return node.field('__listener');
  }

  static inline function getHandlers(node:Node):Dynamic {
    if (node.field('__handlers') == null) {
      node.setField('__handlers', {});
    }
    return node.field('__handlers');
  }

}
