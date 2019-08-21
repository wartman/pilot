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

  public var style(get, set):Style;

  function get_style() {
    return this.style;
  }

  function set_style(style:Style) {
    if (this.props.hasField('className')) {
      this.props.setField('className', [ style, this.props.field('className') ].join(' '));
    } else {
      this.props.setField('className', style);
    }
    this.style = Style.compose([ this.style, style ]);
    return style;
  }

  public function new(impl:VNodeOptions) {
    this = impl;
    if (impl.type == null) {
      this.type = VNodeElement;
    }
    if (impl.props == null) {
      impl.props = {};
    }
    if (impl.children == null) {
      impl.children = [];
    }
    this.children = impl.children.filter(c -> c != null);
    if (impl.props.hasField('key')) {
      this.key = impl.props.field('key');
      this.props.deleteField('key');
    }
    if (impl.style != null) {
      if (impl.props.hasField('className')) {
        this.props.setField('className', [ impl.style, impl.props.field('className') ].join(' '));
      } else {
        this.props.setField('className', impl.style);
      }
    }
    #if js
      if (impl.hooks == null) {
        this.hooks = {};
      }
    #end
  }

}
