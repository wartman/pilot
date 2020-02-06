package pilot;

import pilot.dom.*;

interface Wire<Attrs> {
  public function __dispose():Void;
  public function __getReal():Node;
  public function __getCursor():Cursor;
  public function __isUpdating():Bool;
  public function __insertInto(parent:Wire<Dynamic>):Void;
  public function __removeFrom(parent:Wire<Dynamic>):Void;
  public function __update(attrs:Attrs, children:Array<VNode>, context:Context):Void;
}
