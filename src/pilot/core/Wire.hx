package pilot.core;

interface Wire<Attrs, Real:{}> {
  public function _pilot_dispose():Void;
  public function _pilot_getReal():Real;
  public function _pilot_appendChild(child:Wire<Dynamic, Real>):Void;
  public function _pilot_removeChild(child:Wire<Dynamic, Real>):Void;
  public function _pilot_insertInto(parent:Wire<Dynamic, Real>):Void;
  public function _pilot_removeFrom(parent:Wire<Dynamic, Real>):Void;
  public function _pilot_update(attrs:Attrs, context:Context):Void;
  public function _pilot_updateChildren(children:Array<VNode<Real>>, context:Context):Void;
}
