package pilot2;

import js.html.Node;

using Lambda;
using Reflect;

enum VNodeDef {
  VNodeElement(
    name:String,
    props:{},
    ?children:Array<VNode>
  );
  VNodeComponent(component:Component);
  VNodeText(content:String);
  VNodeSafe(content:String);
  VNodeFragment(children:Array<VNode>);
  VNodePlaceholder(?label:String);
}

typedef VNodeObject = {
  vnode:VNodeDef,
  ?key:String,
  ?hooks:Array<Hook>,
  ?node:Node,
  ?isRecycled:Bool
}; 

@:forward
abstract VNode(VNodeObject) from VNodeObject {
  
  @:from public static function ofArray(children:Array<VNode>):VNode {
    return { vnode: VNodeFragment(children) };
  }

  @:from public static function ofComponent(component:Component):VNode {
    return { vnode: VNodeComponent(component) };
  }

  @:from public static function ofText(content:String):VNode {
    return { vnode: VNodeText(content) };
  }

  public function new(options:{
    name:String,
    ?key:String,
    ?props:{},
    ?hooks:Array<Hook>,
    ?children:Array<VNode>,
    ?isRecycled:Bool
    // ?style:Style
  }) {
    this = {
      vnode: VNodeElement(
        options.name,
        options.props != null ? options.props : {},
        options.children != null ? options.children : []
        // options.style
      ),
      key: options.key == null
        ? options.props.hasField('key')
          ? options.props.field('key')
          : null
        : options.key,
      hooks: options.hooks,
      node: null
    };
  }

  inline public function isSvg():Bool {
    return switch this.vnode {
      case VNodeElement(name, _, _): name == 'svg';
      default: false;
    }
  }

  inline public function setNode(node:Node):VNode {
    this.node = node;
    return this;
  }

  inline public function markRecycled():VNode {
    this.isRecycled = true;
    return this;
  }

  inline public function hasNode():Bool {
    return this.node != null;
  }

  public function addHook(hook:Hook):VNode {
    if (this.hooks == null) {
      this.hooks = [];
    }
    this.hooks.push(hook);
    return this;
  }

  public function addClassName(name:String):VNode {
    switch this.vnode {
      case VNodeElement(name, props, children):
        var className = switch [ (props.field('className'):String), name ] {
          case [ null, null ]: null;
          case [ null, v ] | [ v, null ] : v;
          case [ a, b ] if (!a.split(' ').has(b)): '$a $b';
          default: name;
        }
        if (className != null) {
          props.setField('className', className);
        }
        this.vnode = VNodeElement(name, props, children);
      default:
    }
    return this;
  }

  public function appendChild(child:VNode) {
    switch this.vnode {
      case VNodeElement(name, props, children):
        this.vnode = VNodeElement(name, props, children.concat([ child ]));
      default: 
        // throw an error??
    }
    return this;
  }

  public function appendChildren(children:Array<VNode>) {
    switch this.vnode {
      case VNodeElement(name, props, existing):
        this.vnode = VNodeElement(name, props, existing.concat(children));
      default: 
        // throw an error??
    }
    return this;
  }

}
