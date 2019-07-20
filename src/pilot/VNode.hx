package pilot;

#if js
  import js.html.Node;
#end

using Reflect;

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

typedef VNodeOptions = {
  name:String,
  props:{},
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
abstract VNode(VNodeOptions) {

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

  static public inline function h(name:String, props:{}, ?children:Array<VNode>) {
    return new VNode({
      name: name,
      props: props,
      children: children != null ? children : []
    });
  }

  static public inline function element(impl:VNodeOptions) {
    return new VNode(impl);
  }

  static public inline function fragment(nodes:Array<VNode>) {
    return new VNode({
      name: '',
      props: {},
      children: nodes,
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

  public function new(impl:VNodeOptions) {
    this = impl;
    if (impl.type == null) {
      this.type = VNodeElement;
    }
    if (impl.children == null) {
      this.children = [];
    }
    this.children = this.children.filter(c -> c != null);
    if (impl.props.hasField('key')) {
      this.key = impl.props.field('key');
      this.props.deleteField('key');
    }
    #if js
      if (impl.hooks == null) {
        this.hooks = {};
      }
    #end
  }

}
