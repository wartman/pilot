package pilot;

#if js
  typedef Node = js.html.Node;
#else
  typedef Node = pilot.target.sys.Node;
#end