package pilot2;

import haxe.DynamicAccess;

using Reflect;
using StringTools;

class Renderer {
  
  public static function render(vNode:VNode) {
    return switch vNode.type {

      case VNodeElement(name, props, children):
        var out = '<${name}';
        var innerHtml = if (props.hasField('innerHTML')) {
          var ret = props.field('innerHTML');
          props.deleteField('innerHTML');
          ret;
        } else null;
        var attrs = handleAttributes(props);
        if (attrs.length > 0) {
          out += ' ' + attrs.join(' ');
        }
        if (children.length == 0) {
          if (innerHtml != null) {
            return '${out}>${innerHtml}</${name}>';
          } else {
            // Todo: check if this element should be stand-alone.
            return '${out}></${name}>';
          }
        }
        out + '>'
          + [ for (child in children) render(child) ].join('')
          + '</${name}>';
      
      case VNodeText(content):
        content.htmlEscape(true);

      case VNodeSafe(content):
        content;

      case VNodePlaceholder(_):
        '';

      case VNodeFragment(children):
        children.map(render).join('');

      case VNodeState(state):
        render(state.build());
        
    }
  }

  static function handleAttributes(props:DynamicAccess<Dynamic>) {
    return [ for (k => v in props) {
      if (v == null || v == false)
        null
      else if (v == true)
        '${k}="${k}"'
      else 
        switch k {
          case 'className' | 'classname': 'class="${Std.string(v)}"';
          default: '${k}="${Std.string(v)}"';
        }
    }].filter(v -> v != null);
  }


}