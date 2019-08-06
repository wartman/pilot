package pilot;

using pilot.Style;

@:deprecated('Use `pilot.Style.applyStyle` instead')
abstract StyledWidget(VNode) to VNode {

  public inline function new(props:{
    style:Style,
    child:VNode
  }) {
    this = props.child.applyStyle(props.style);
  }

}
