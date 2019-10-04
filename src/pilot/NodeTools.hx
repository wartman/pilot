package pilot;

import js.html.Node;
import js.html.Event;

using Reflect;

class NodeTools {

  inline static final vNodeField = '_pilot_vNode';
  inline static final listenerField = '_pilot_listener';
  inline static final handlerField = '_pilot_handler';
  
  inline public static function setVNode(node:Node, vNode:VNode) {
    node.setField(vNodeField, vNode);
  }

  inline public static function getVNode(node:Node):VNode {
    return node.field(vNodeField);
  }

  inline public static function getListener(node:Node):(event:Event)->Void {
    if (node.field(listenerField) == null) {
      node.setField(listenerField, function (event:Event) {
        var cb:(e:Event)->Void = getHandlers(node).field(event.type);
        if (cb != null) cb(event);
      });
    }
    return node.field(listenerField);
  }

  inline public static function getHandlers(node:Node):Dynamic {
    if (node.field(handlerField) == null) {
      node.setField(handlerField, {});
    }
    return node.field(handlerField);
  }

}
