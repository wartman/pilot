package pilot;

abstract StyleProvider(VNode) to VNode {
  
  public inline function new(props:{
    child:VNode,
    ?theme:StyleSheet
  }) {
    if (props.theme == null) {
      props.theme = StyleSheet.getInstance();
    }
    props.theme.inject();
    this = props.child;
  }

}
