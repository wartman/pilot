package pilot;

enum VNode {
  VNative<Attrs:{}>(
    type:WireType<Attrs>,
    attrs:Attrs,
    children:Array<VNode>,
    ?key:Key,
    ?ref:(node:Any)->Void,
    ?dangerouslySetInnerHtml:String
  );
  VComponent<Attrs:{}>(
    type:WireType<Attrs>,
    attrs:Attrs,
    ?key:Key
  );
  VFragment(children:Array<VNode>);
}
