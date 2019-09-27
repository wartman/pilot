package pilot2;

import js.Browser;
import js.html.Node;
import js.html.Element;
import js.html.Event;
import haxe.DynamicAccess;

using Reflect;
using StringTools;
using Type;

class Differ {

  public final hooks:HookManager = [];
  final eventPrefix = 'on';
  final nodeKey = 'key';

  public function new() { }
  
  public function patch(node:Node, vnode:VNode) {
    node = patchNode(
      node,
      node,
      if (getNodeVNode(node) != null)
        getNodeVNode(node)
      else
        recycleNode(node),
      vnode,
      vnode.isSvg()
    );
    setNodeVNode(node, vnode);
    return vnode;
  }

  public function subPatch(vNode:VNode, newVNode:VNode) {
    patchNode(
      vNode.node,
      vNode.node,
      vNode,
      newVNode,
      newVNode.isSvg()
    );
    vNode.vnode = newVNode.vnode;
    vNode.key = newVNode.key;
    vNode.hooks = newVNode.hooks;
  }

  function recycleNode(node:Node):VNode {
    return node.nodeType == 3
      ? {
          vnode: VNodeText(node.nodeValue),
          hooks: [],
          node: node,
          isRecycled: true
        }
      : new VNode({
          name: node.nodeName.toLowerCase(),
          children: [ for (n in node.childNodes) recycleNode(n) ],
        }).setNode(node).markRecycled();
  }

  function patchNode(
    parent:Node,
    node:Node,
    oldVNode:VNode,
    newVNode:VNode,
    isSvg:Bool
  ):Node {

    function finish(didPatch:Bool = true) {
      if (didPatch) {
        newVNode.hooks.doPostPatchHook(oldVNode, newVNode);
        hooks.doPostPatchHook(oldVNode, newVNode);
      }

      newVNode.hooks.doPostHook();
      hooks.doPostHook();

      newVNode.setNode(node);
      return node;
    }

    function insert(doRemove:Bool = false) {
      node = parent.insertBefore(createNode(newVNode, isSvg), node);
      if (doRemove && oldVNode != null && oldVNode.node != null) {
        removeNode(parent, oldVNode);
      }
      newVNode.setNode(node);
      newVNode.hooks.doInsertHook(newVNode);
      hooks.doInsertHook(newVNode);
    }

    newVNode.hooks.doPreHook();
    hooks.doPreHook();

    if (oldVNode == newVNode) {
      return finish(false);
    }

    newVNode.hooks.doPrePatchHook(oldVNode, newVNode);
    hooks.doPrePatchHook(oldVNode, newVNode);

    if (oldVNode == null) {
      insert(false);
      return finish();
    }

    switch oldVNode.vnode {

      case VNodeText(content): switch newVNode.vnode {

        case VNodeText(newContent) if (content != newContent): 
          newVNode.hooks.doUpdateHook(oldVNode, newVNode);
          hooks.doUpdateHook(oldVNode, newVNode);
          node.nodeValue = newContent;
          return finish();

        case VNodeText(newContent) if (content == newContent):
          return finish();
          
        default:

      }

      case VNodeElement(oldName, oldProps, oldChildren): switch newVNode.vnode {

        case VNodeElement(newName, newProps, newChildren) if (oldName == newName):
          
          isSvg = isSvg || newVNode.isSvg();

          newVNode.hooks.doUpdateHook(oldVNode, newVNode);
          hooks.doUpdateHook(oldVNode, newVNode);

          for (k => _ in mergeProps(oldProps, newProps)) {
            switch k {
              case 'value' | 'selected' | 'checked':
                if (node.field(k) != newProps.field(k)) {
                  patchProperty(
                    node,
                    k,
                    oldProps.field(k),
                    newProps.field(k), 
                    isSvg
                  );
                }
              default:
                if (oldProps.field(k) != newProps.field(k)) {
                  patchProperty(
                    node,
                    k,
                    oldProps.field(k),
                    newProps.field(k),
                    isSvg
                  );
                }
            }
          }

          patchChildren(
            node,
            oldChildren,
            newChildren,
            isSvg,
            oldVNode.isRecycled
          );

          return finish();

        default:          
      }

      case VNodePlaceholder(oldLabel): switch newVNode.vnode {
        case VNodePlaceholder(newLabel) if (oldLabel == newLabel):
          return finish();
        default:
      }

      case VNodeFragment(oldChildren): switch newVNode.vnode {

        case VNodeFragment(newChildren):
          patchChildren(
            parent, // I think?
            oldChildren,
            newChildren,
            isSvg,
            oldVNode.isRecycled
          );
          
          return finish();

        default:
      }

      case VNodeSafe(oldContent): switch newVNode.vnode {

        case VNodeSafe(newContent) if (oldContent == newContent):
          return finish();
        
        default:

      }

      case VNodeState(oldState): switch newVNode.vnode {
        
        // todo: figure out how you want to handle state.
        //       right now it is a mess.
      
        default:

      }

    }

    insert(true);
    return finish();
  }

  function patchProperty(
    node:Node,
    key:String,
    oldValue:Dynamic,
    newValue:Dynamic,
    isSvg:Bool
  ) {
    if (key == nodeKey) return;

    if (key.startsWith(eventPrefix)) {
      var event = key.substr(eventPrefix.length).toLowerCase();
      var listener = getListener(node);
      getHandlers(node).setField(event, newValue);
      if (newValue == null) {
        node.removeEventListener(event, listener);
      } else if (oldValue == null) {
        node.addEventListener(event, listener);
      }
    } else if (
      newValue == null 
      || newValue == false
      || (Std.is(newValue, String) && newValue.length == 0)
    ) {
      var el:Element = cast node;
      el.removeAttribute(key);
    } else {
      var el:Element = cast node;
      if (key == 'className') key = 'class';
      if (key == 'htmlFor') key = 'for';
      el.setAttribute(key, newValue);
    }
  }

  function patchChildren(
    node:Node,
    oldChildren:Array<VNode>,
    newChildren:Array<VNode>,
    isSvg:Bool,
    isRecycled:Bool
  ) {
    var tmpChild;
    var oldChild;
    var oldKey:String;
    var newKey:String;
    var oldHead = 0;
    var newHead = 0;
    var oldTail = oldChildren.length - 1;
    var newTail = newChildren.length - 1;

    while (newHead <= newTail && oldHead <= oldTail) {
      if (
        (oldKey = getKey(oldChildren[oldHead])) == null
        || oldKey != getKey(newChildren[newHead])
      ) {
        break;
      }

      patchNode(
        node,
        oldChildren[oldHead].node,
        oldChildren[oldHead++],
        newChildren[newHead++],
        isSvg
      );        
    }

    if (oldHead > oldTail) {
      while (newHead <= newTail) {
        node.insertBefore(
          createNode(newChildren[newHead++], isSvg),
          (oldChild = oldChildren[oldHead]) != null 
            ? oldChild.node 
            : null
        );
      }
    } else if (newHead > newTail) {
      while (oldHead <= oldTail) {
        removeNode(node, oldChildren[oldHead++]);
      }
    } else {
      var keyed:DynamicAccess<VNode> = {};
      var newKeyed:DynamicAccess<Bool> = {};

      var i = oldHead;
      while (i <= oldTail) {
        if ((oldKey = oldChildren[i].key) != null) {
          keyed.set(oldKey, oldChildren[i]);
        }
        i++;
      }

      while (newHead <= newTail) {
        oldKey = getKey((oldChild = oldChildren[oldHead]));
        newKey = getKey(newChildren[newHead]);

        if (
          newKeyed.get(oldKey)
          || (newKey != null && newKey == getKey(oldChildren[oldHead + 1]))
        ) {
          if (oldKey == null) {
            removeNode(node, oldChild);
          }
          oldHead++;
          continue;
        }

        if (newKey == null || isRecycled) {
          if (oldKey == null) {
            patchNode(
              node, 
              oldChild != null ? oldChild.node : null,
              oldChild,
              newChildren[newHead],
              isSvg
            );
            newHead++;
          }
          oldHead++;
        } else {
          if (oldKey == newKey) {
            patchNode(
              node,
              oldChild.node,
              oldChild,
              newChildren[newHead],
              isSvg
            );
            newKeyed.set(newKey, true);
            oldHead++;
          } else {
            if ((tmpChild = keyed.get(newKey)) != null) {
              patchNode(
                node,
                node.insertBefore(
                  tmpChild.node,
                  oldChild != null ? oldChild.node : null
                ),
                tmpChild,
                newChildren[newHead],
                isSvg
              );
              newKeyed.set(newKey, true);
            } else {
              patchNode(
                node,
                oldChild != null ? oldChild.node : null,
                null,
                newChildren[newHead],
                isSvg
              );
            }
          }
          newHead++;
        }
      }

      while (oldHead <= oldTail) {
        if (getKey((oldChild = oldChildren[oldHead++])) == null) {
          removeNode(node, oldChild);
        }
      }

      for (k => vnode in keyed) {
        if (newKeyed.get(k) == null) {
          removeNode(node, vnode);
        }
      }

    }
  }

  function createNode(vn:VNode, isSvg:Bool):Node {
    if (vn.isSvg()) isSvg = true;

    vn.hooks.doCreateHook(vn);
    hooks.doCreateHook(vn);

    vn.hooks.doUpdateHook(null, vn);
    hooks.doUpdateHook(null, vn);
    
    var node = switch vn.vnode {
      case VNodeElement(name, props, children):
        var n = Browser.document.createElement(name);
        for (key => value in (props:DynamicAccess<Dynamic>)) {
          patchProperty(n, key, null, value, isSvg);
        }
        for (child in children) {
          n.appendChild(createNode(child, isSvg));
        }
        n;
      case VNodeText(content):
        Browser.document.createTextNode(content);
      case VNodeFragment(children):
        var n = Browser.document.createDocumentFragment();
        for (child in children) {
          n.appendChild(createNode(child, isSvg));
        }
        n;
      case VNodePlaceholder(label):
        Browser.document.createComment(label == null ? '' : label);
      case VNodeSafe(content):
        var n = Browser.document.createDivElement();
        n.innerHTML = content;
        n;
      case VNodeState(state):
        var vn = state.build();
        state.mount(this, vn);
        createNode(vn, isSvg);
    }

    vn.setNode(node);
    return node;
  }

  function removeNode(parent:Node, vnode:VNode) {
    vnode.hooks.doRemoveHook(vnode);
    vnode.hooks.doDestroyHook(vnode);
    hooks.doRemoveHook(vnode);
    if (!parent.contains(vnode.node)) {
      return;
    }
    parent.removeChild(vnode.node);
  }

  inline public function setNodeVNode(node:Node, vnode:VNode) {
    node.setField('__vnode', vnode);
  }

  inline public function getNodeVNode(node:Node) {
    return node.field('__vnode');
  }
  
  inline function getListener(node:Node) {
    if (node.field('__listener') == null) {
      node.setField('__listener', function (event:Event) {
        var cb:(e:Event)->Void = getHandlers(node).field(event.type);
        if (cb != null) cb(event);
      });
    }
    return node.field('__listener');
  }

  inline function getHandlers(node:Node):Dynamic {
    if (node.field('__handlers') == null) {
      node.setField('__handlers', {});
    }
    return node.field('__handlers');
  }

  function getKey(?vnode:VNode) {
    return if (vnode == null) null else vnode.key; 
  }

  function mergeProps(a:{}, b:{}):DynamicAccess<Dynamic> {
    var out:DynamicAccess<Dynamic> = new DynamicAccess();
    for (k => v in (a:DynamicAccess<Dynamic>)) out.set(k, v);
    for (k => v in (b:DynamicAccess<Dynamic>)) out.set(k, v);
    return out;
  }

}
