package pilot;

import pilot.diff.VNode;

#if js
  import js.html.Node;
  
  typedef Children = Array<VNode<Node>>;
#end
