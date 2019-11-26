package pilot;

interface Wire<Attrs> {
  public function _pilot_dispose():Void;
  public function _pilot_getReal():Node;
  public function _pilot_insertInto(parent:Wire<Dynamic>):Void;
  public function _pilot_removeFrom(parent:Wire<Dynamic>):Void;
  public function _pilot_update(attrs:Attrs, children:Array<VNode>, context:Context):Void;
}
