package pilot;

import haxe.DynamicAccess;

using Reflect;
using StringTools;
using pilot.VNodeTools;

class Renderer {
  
  public static function render(vnode:VNode) {
    if (vnode.style != null) {
      vnode.addClassName(vnode.style);
      vnode.style = null;    
    }

    return switch vnode.type {
      case VNodeElement | VNodeRecycled:
        var out = '<${vnode.name}';
        var innerHtml = if (vnode.props.hasField('innerHTML')) {
          var ret = vnode.props.field('innerHTML');
          vnode.props.deleteField('innerHTML');
          ret;
        } else null;
        var attrs = handleAttributes(vnode.props);
        if (attrs.length > 0) {
          out += ' ' + attrs.join(' ');
        }
        if (vnode.children.length == 0) {
          if (innerHtml != null) {
            return '${out}>${innerHtml}</${vnode.name}>';
          } else {
            return '${out}/>';
          }
        }
        out 
          + [ for (child in vnode.children) render(child) ].join('')
          + '</${vnode.name}>';
      case VNodeFragment:
        [ for (child in vnode.children) render(child) ].join('');
      case VNodePlaceholder:
        '';
      case VNodeText:
        vnode.name.htmlEscape(true);
    }
  }

  static function handleAttributes(props:DynamicAccess<Dynamic>) {
    return [ for (k => v in props) switch v {
      case true: '${k} = "${k}"';
      case false: null;
      default: '${k} = "${Std.string(v)}"';
    } ].filter(v -> v != null);
  }

}
