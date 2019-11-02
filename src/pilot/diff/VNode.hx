package pilot.diff; 

enum VNode<Real:{}> {
  VNative<Attrs>(type:NodeType<Attrs, Real>, attrs:Attrs, children:Array<VNode<Real>>, ?key:Key);
  VWidget<Attrs>(type:WidgetType<Attrs, Real>, attrs:Attrs, ?key:Key);
  VFragment(children:Array<VNode<Real>>);
}
