package pilot;

class FragmentWire extends NodeWire<Dynamic> {
  
  public static function _pilot_create(attrs:Dynamic, context:Context):Wire<Dynamic> {
    return new FragmentWire();
  }

  var parent:Wire<Dynamic>;
  var later:()->Void;

  public function new() {
    super(null, false);
  }

  override function _pilot_insertInto(parent:Wire<Dynamic>) {
    this.parent = parent;
    real = parent._pilot_getReal();
    if (later != null) {
      later();
      later = null;
    }
  }

  override function _pilot_removeFrom(parent:Wire<Dynamic>) {
    for (c in childList) c._pilot_removeFrom(parent);
    _pilot_dispose();
  }

  override function _pilot_dispose() {
    later = null;
    parent = null;
    types = null;
    childList = null;
  }

  override function _pilot_updateChildren(children:Array<VNode>, context:Context) {
    if (parent != null) {
      super._pilot_updateChildren(children, context);
    } else {
      later = () -> _pilot_updateChildren(children, context);
    }
  }
  
}
