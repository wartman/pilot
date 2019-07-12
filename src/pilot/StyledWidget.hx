package pilot;

using Reflect;

abstract StyledWidget(VNode) to VNode {

  public function new(props:{
    compose:Array<Style>,
    child:VNode
  }) {
    this = props.child;
    if (this.props.hasField('className')) {
      props.compose.push(new Style(this.props.field('className')));
    }
    this.props.setField('className', Style.compose(props.compose));
  }

}
