package pilot;

import pilot.dom.Node;

interface Wire<Attrs> {
  public function __update(
    attrs:Attrs,
    children:Array<VNode>,
    context:Context,
    later:Later
  ):Void;
  public function __getNodes():Array<Node>;
  public function __setup(parent:Wire<Dynamic>):Void;
  public function __dispose():Void;
}
