package pilot2;

import pilot2.diff.VNode;

#if js
  import js.html.Node;
  
  typedef Children = Array<VNode<Node>>;
#end
