package pilot;

import pilot.dom.*;

enum VNode {
  VNative<Attrs>(
    type:WireType<Attrs>,
    attrs:Attrs,
    children:Array<VNode>,
    ?key:Key,
    ?ref:(node:Node)->Void
  );
  VComponent<Attrs>(
    type:WireType<Attrs>,
    attrs:Attrs,
    ?key:Key
  );
  VFragment(children:Array<VNode>);
}
