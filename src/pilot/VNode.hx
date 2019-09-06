package pilot;

#if js
  import js.html.Node;
#end

using Reflect;
using StringTools;

enum VNodeType {
  VNodeElement;
  VNodeText;
  VNodeRecycled;
  VNodeFragment;
  VNodePlaceholder;
}

abstract VNodeKey(String) from String to String {

  @:from public static inline function ofInt(value:Int) {
    return new VNodeKey(Std.string(value));
  } 

  public function new(name:String) {
    this = name;
  }

}

typedef VNodeImpl = {
  name:String,
  ?props:{},
  ?style:Style,
  ?type:VNodeType,
  ?children:Array<VNode>,
  ?key:VNodeKey,
  #if js
    ?hooks: {
      ?attach:(vnode:VNode)->Void,
      ?detach:()->Void,
      ?willPatch:(newVNode:VNode)->VNode,
    },
    ?node:Node
  #end
};

@:forward
abstract VNode(VNodeImpl) {

  static public inline function text(value:String #if js, ?node:Node #end) {
    return new VNode({
      name: value,
      props: {},
      type: VNodeText,
      #if js
        node: node
      #end
    });
  }

  static public inline function placeholder() {
    return new VNode({
      name: '[placeholder]',
      props: {},
      type: VNodePlaceholder
    });
  }

  @:deprecated('Use new VNode({...}) instead')
  static public inline function h(name:String, props:{}, ?children:Array<VNode>) {
    return new VNode({
      name: name,
      props: props,
      children: children != null ? children : []
    });
  }

  static public inline function element(impl:VNodeImpl) {
    return new VNode(impl);
  }

  static public inline function fragment(children:Array<VNode>) {
    return new VNode({
      name: '',
      props: {},
      children: children,
      type: VNodeFragment
    });
  }
  
  @:from public static inline function ofWidget(widget:Widget) {
    return widget.render();
  }

  @:from static public inline function ofString(value:String) {
    return text(value);
  }

  @:from static public inline function ofInt(value:Int) {
    return text(Std.string(value));
  }

  @:from static public inline function ofArray(value:Array<VNode>) {
    return fragment(value);
  }

  public function new(impl:VNodeImpl) {
    if (impl.type == null) {
      impl.type = VNodeElement;
    }
    if (impl.props == null) {
      impl.props = {};
    }
    if (impl.children == null) {
      impl.children = [];
    }
    impl.children = impl.children.filter(c -> c != null);
    if (impl.props.hasField('key')) {
      impl.key = impl.props.field('key');
      impl.props.deleteField('key');
    }
    #if js
      if (impl.hooks == null) {
        impl.hooks = {};
      }
    #end
    this = impl;
  }

}
