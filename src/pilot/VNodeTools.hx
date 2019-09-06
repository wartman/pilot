package pilot;

using Lambda;
using Reflect;

class VNodeTools {

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

  public inline static function addStyle(vnode:VNode, style:Style):VNode {
    vnode.style = Style.compose([ vnode.style, style ]);
    return vnode;
  }

}
