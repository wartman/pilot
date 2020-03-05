package pilot;

import pilot.dom.Node;

interface Wire<Attrs> {
  public function __update(
    attrs:Attrs,
    children:Array<VNode>,
    later:Signal<Any>
  ):Void;
  public function __getNodes():Array<Node>;
  public function __setup(
    parent:Wire<Dynamic>, 
    context:Context
  ):Void;
  public function __dispose():Void;
}
