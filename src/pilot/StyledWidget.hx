package pilot;

using pilot.Style;

abstract StyledWidget(VNode) to VNode {

  @:deprecated('Use `pilot.Style.applyStyle` instead')
  public inline function new(props:{
    style:Style,
    child:VNode
  }) {
    this = props.child.applyStyle(props.style);
  }

}
