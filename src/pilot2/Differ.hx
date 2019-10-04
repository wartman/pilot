package pilot2;

import js.Browser;
import js.html.Node;
import js.html.Element;
import js.html.Event;
import haxe.DynamicAccess;

using Reflect;
using StringTools;
using pilot2.NodeTools;

/**
  Diff a HTML node.

  Most of this code, especially the core of the diffing algorithm
  in `patchChildren`, is based on/taken directly 
  from https://github.com/jorgebucaran/superfine. The main changes
  were adding `Hooks` and using Haxe's enums. 
**/
class Differ {

  static final eventPrefix = 'on';
  static final nodeKey = 'key';

  final context:Context;

  public function new(context) {
    this.context = context;
  }
  
  public function patch(node:Node, vNode:VNode):Node {
    node = patchNode(
      node.parentNode != null
        ? node.parentNode
        : node,
      node,
      if (node.getVNode() != null)
        node.getVNode()
      else
        recycleNode(node),
      vNode,
      vNode.isSvg()
    );
    node.setVNode(vNode);
    return node;
  }

  public function subPatch(vNode:VNode, newVNode:VNode):Void {
    var node = patchNode(
      vNode.node.parentNode,
      vNode.node,
      vNode,
      newVNode,
      newVNode.isSvg()
    );
    vNode.type = newVNode.type;
    vNode.key = newVNode.key;
    vNode.hooks = newVNode.hooks;
    vNode.node = node;
    node.setVNode(vNode);
  }

  function recycleNode(node:Node):VNode {
    return node.nodeType == 3
      ? {
          type: VNodeText(node.nodeValue),
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
        context.hooks.doPostPatchHook(oldVNode, newVNode);
      }

      newVNode.hooks.doPostHook();

      newVNode.setNode(node);
      return node;
    }

    function insert(doRemove:Bool = false) {
      node = parent.insertBefore(createNode(newVNode, isSvg), node);
      if (doRemove && oldVNode != null && oldVNode.node != null) {
        removeNode(parent, oldVNode);
      }
      newVNode.hooks.doInsertHook(newVNode);
      context.hooks.doInsertHook(newVNode);
    }

    newVNode.hooks.doPreHook();

    if (oldVNode == newVNode) {
      return finish(false);
    }

    newVNode.hooks.doPrePatchHook(oldVNode, newVNode);
    context.hooks.doPrePatchHook(oldVNode, newVNode);

    if (oldVNode == null) {
      insert(false);
      return finish(false);
    }

    switch oldVNode.type {

      case VNodeText(content): switch newVNode.type {

        case VNodeText(newContent) if (content != newContent): 
          newVNode.hooks.doUpdateHook(oldVNode, newVNode);
          context.hooks.doUpdateHook(oldVNode, newVNode);
          node.nodeValue = newContent;
          return finish();

        case VNodeText(newContent) if (content == newContent):
          return finish();
          
        default:

      }

      case VNodeElement(oldName, oldProps, oldChildren): switch newVNode.type {

        case VNodeElement(newName, newProps, newChildren) if (oldName == newName):
          
          isSvg = isSvg || newVNode.isSvg();

          newVNode.hooks.doUpdateHook(oldVNode, newVNode);
          context.hooks.doUpdateHook(oldVNode, newVNode);

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

      case VNodePlaceholder(oldLabel): switch newVNode.type {
        case VNodePlaceholder(newLabel) if (oldLabel == newLabel):
          return finish();
        default:
      }

      case VNodeFragment(oldChildren): switch newVNode.type {

        case VNodeFragment(newChildren):
          newVNode.hooks.doUpdateHook(oldVNode, newVNode);
          context.hooks.doUpdateHook(oldVNode, newVNode);

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

      case VNodeSafe(oldContent): switch newVNode.type {

        case VNodeSafe(newContent) if (oldContent == newContent):
          return finish();

        case VNodeSafe(newContent) if (oldContent != newContent):
          newVNode.hooks.doUpdateHook(oldVNode, newVNode);
          context.hooks.doUpdateHook(oldVNode, newVNode);

          var el:Element = cast node;
          el.innerHTML = newContent;

          return finish();
          
        default:

      }

      case VNodeRenderable(oldR): 
        var realNode = oldR._pilot_getVNode();
        
        switch newVNode.type {

          // // Todo: this is probably a place for optimization!
          // case VNodeRenderable(newR) if (oldR._pilot_getId() == newR._pilot_getId()):
          case VNodeRenderable(newR):
            node = patchNode(
              parent,
              realNode.node,
              realNode,
              newR.render(context),
              isSvg
            );
            oldR.dispose();
            return finish();

          default:
            node = patchNode(
              parent, 
              realNode.node, 
              realNode,
              newVNode,
              isSvg
            );
            oldR.dispose();
            return finish();

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
      var listener = node.getListener();
      node.getHandlers().setField(event, newValue);
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
        patchNode(
          node,
          (oldChild = oldChildren[oldHead]) != null 
            ? oldChild.node 
            : null,
          null,
          newChildren[newHead++],
          isSvg
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

      for (k => vNode in keyed) {
        if (newKeyed.get(k) == null) {
          removeNode(node, vNode);
        }
      }

    }
  }

  function createNode(vn:VNode, isSvg:Bool):Node {
    if (vn.isSvg()) isSvg = true;

    vn.hooks.doCreateHook(vn);
    context.hooks.doCreateHook(vn);

    vn.hooks.doUpdateHook(null, vn);
    context.hooks.doUpdateHook(null, vn);

    // If a child vNode is not passed through `patchNode`,
    // we'll need to mock up its lifecyle.
    function createWithLifecycle(child:VNode) {
      child.hooks.doPreHook();

      child.hooks.doPrePatchHook(null, child);
      context.hooks.doPrePatchHook(null, child);
      
      var node = createNode(child, isSvg);
      
      child.hooks.doInsertHook(child);
      context.hooks.doInsertHook(child);
      
      child.hooks.doPostPatchHook(null, child);
      context.hooks.doPostPatchHook(null, child);
      
      child.hooks.doPostHook();
      
      return node;
    }
    
    var node = switch vn.type {
      case VNodeElement(name, props, children):
        var n = Browser.document.createElement(name);
        for (key => value in (props:DynamicAccess<Dynamic>)) {
          patchProperty(n, key, null, value, isSvg);
        }
        for (child in children) {
          patchNode(n, null, null, child, isSvg);
        }
        n;
      case VNodeText(content):
        Browser.document.createTextNode(content);
      case VNodeFragment(children):
        var n = Browser.document.createDocumentFragment();
        for (child in children) {
          n.appendChild(createWithLifecycle(child));
        }
        n;
      case VNodePlaceholder(label):
        Browser.document.createComment(label == null ? '' : label);
      case VNodeSafe(content):
        var n = Browser.document.createDivElement();
        n.innerHTML = content;
        n;
      case VNodeRenderable(renderable):
        createWithLifecycle(renderable.render(context));
    }

    vn.setNode(node);
    return node;
  }

  function removeNode(parent:Node, vNode:VNode) {
    var n = vNode.node;
    if (parent.contains(n)) {
      parent.removeChild(n);
    }
    vNode.hooks.doRemoveHook(vNode);
    vNode.hooks.doDestroyHook(vNode);
    context.hooks.doRemoveHook(vNode);
  }

  function getKey(?vNode:VNode) {
    return if (vNode == null) null else vNode.key; 
  }

  function mergeProps(a:{}, b:{}):DynamicAccess<Dynamic> {
    var out:DynamicAccess<Dynamic> = new DynamicAccess();
    for (k => v in (a:DynamicAccess<Dynamic>)) out.set(k, v);
    for (k => v in (b:DynamicAccess<Dynamic>)) out.set(k, v);
    return out;
  }

}
