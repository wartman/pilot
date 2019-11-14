package pilot.core;

// Todo: The use of _pilot_appendChild, _pilot_removeChild, _pilot_insertInto
// and _pilot_removeFrom is a bit confusing. Clean the API up -- it should make 
// implementation a bit easer to maintain. Right now it's unclear if, for example,
// `_pilot_dispose` is correctly called all the time.
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
