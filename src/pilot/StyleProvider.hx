package pilot;

abstract StyleProvider(VNode) to VNode {
  
  public inline function new(props:{
    child:VNode,
    ?manager:StyleSheet
  }) {
    if (props.manager == null) {
      props.manager = StyleSheet.getInstance();
    }
    props.manager.inject();
    this = props.child;
  }

}
