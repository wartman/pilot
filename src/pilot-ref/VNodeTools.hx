package pilot;

using Lambda;
using Reflect;

/**
  Various tools to assist working with VNodes.
**/
class VNodeTools {

  /**
    Add a class name to a VNode. Will keep existing class names
    and will ensure class names are not duplicated.
  **/
  public static function addClassName(vnode:VNode, name:String):VNode {
    var className = switch [ (vnode.props.field('className'):String), name ] {
      case [ null, null ]: null;
      case [ null, v ] | [ v, null ] : v;
      case [ a, b ] if (!a.split(' ').has(b)): '$a $b';
      default: name;
    }
    if (className != null) {
      vnode.props.setField('className', className);
    }
    return vnode;
  }

  /**
    Add a style to a VNode.
  **/
  public inline static function addStyle(vnode:VNode, style:Style):VNode {
    vnode.style = Style.compose([ vnode.style, style ]);
    return vnode;
  }

  /**
    Append a child to a VNode.
  **/
  public inline static function appendChild(vnode:VNode, child:VNode) {
    vnode.children.push(child);
    return vnode;
  }

  /**
    Append children to a VNode.
  **/
  public inline function appendChildren(vnode:VNode, children:Children) {
    vnode.children = vnode.children.concat(children);
    return vnode;
  }

  /**
    Prepend a child to a VNode.
  **/
  public inline static function prependChild(vnode:VNode, child:VNode) {
    vnode.children.unshift(child);
    return vnode;
  }

  /**
    Prepend children to a VNode.
  **/
  public inline function prependChildren(vnode:VNode, children:Children) {
    vnode.children = children.concat(vnode.children);
    return vnode;
  }

}
