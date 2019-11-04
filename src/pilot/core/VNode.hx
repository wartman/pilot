package pilot.core;

enum VNode<Real:{}> {
  VNative<Attrs>(type:NodeType<Attrs, Real>, attrs:Attrs, children:Array<VNode<Real>>, ?key:Key);
  VComponent<Attrs>(type:NodeType<Attrs, Real>, attrs:Attrs, ?key:Key);
  VFragment(children:Array<VNode<Real>>);
}
