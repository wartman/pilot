package pilot;

import haxe.DynamicAccess;

using StringTools;

class Renderer {
  
  public static function render(vnode:VNode) {
    return switch vnode.type {
      case VNodeElement | VNodeRecycled:
        var out = '<${vnode.name}';
        var attrs = handleAttributes(vnode.props);
        if (attrs.length > 0) {
          out += ' ' + attrs.join(' ');
        }
        if (vnode.children.length == 0) {
          return out + '/>';
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
      // todo: allow for unescaped HTML.
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
