package pilot;

using Reflect;

abstract StyledWidget(VNode) to VNode {

  public inline function new(props:{
    style:Style,
    child:VNode
  }) {
    this = props.child;
    if (this.props.hasField('className')) {
      props.style = props.style.add(new Style(this.props.field('className')));
    }
    this.props.setField('className', props.style);
  }

}
