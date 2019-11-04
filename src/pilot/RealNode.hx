package pilot;

#if (js && !nodejs)
  typedef RealNode = js.html.Node;
#else
  typedef RealNode = pilot.sys.Node; 
#end
