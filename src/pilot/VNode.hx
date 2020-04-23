package pilot;

enum VNode {
  VNative<Attrs:{}>(
    type:NativeWireType<Attrs>,
    attrs:Attrs,
    children:Array<VNode>,
    ?key:Key,
    ?ref:(node:Any)->Void,
    ?dangerouslySetInnerHtml:String,
    ?isPlaceholder:Bool
  );
  VComponent<Attrs:{}>(
    type:WireType<Attrs>,
    attrs:Attrs,
    ?key:Key
  );
  VFragment(children:Array<VNode>);
}
