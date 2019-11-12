package pilot.core;

import pilot.core.VNode;
import pilot.core.Context;
import pilot.core.WireBase;
import pilot.core.Wire;

// Todo: this might make more sense to just
//       implement components like this?
class WireFragment<Real:{}> extends WireBase<Dynamic, Real> {
  
  public static function _pilot_create<Real:{}>(attrs:Dynamic, context:Context):Wire<Dynamic, Real> {
    return new WireFragment();
  }

  var parent:Wire<Dynamic, Real>;
  var real:Real;
  var later:()->Void;

  public function new() {}

  override function _pilot_getReal() {
    return real;
  }
  
  override function _pilot_insertInto(parent:Wire<Dynamic, Real>) {
    this.parent = parent;
    real = parent._pilot_getReal();
    if (later != null) {
      later();
      later = null;
    }
  }

  override function _pilot_appendChild(child:Wire<Dynamic, Real>) {
    parent._pilot_appendChild(child);
  }

  override function _pilot_removeChild(child:Wire<Dynamic, Real>) {
    parent._pilot_removeChild(child);
  }

  override function _pilot_removeReal() {
    // noop
  }

  override function _pilot_update(newAttrs:Dynamic, context:Context) {
    // noop
  }

  override function _pilot_removeFrom(parent:Wire<Dynamic, Real>) {
    for (c in childList) c._pilot_removeFrom(parent);
    _pilot_dispose();
  }

  override function _pilot_dispose() {
    later = null;
    parent = null;
    types = null;
    childList = null;
  }

  override function _pilot_updateChildren(children:Array<VNode<Real>>, context:Context) {
    if (parent != null) {
      super._pilot_updateChildren(children, context);
    } else {
      later = () -> _pilot_updateChildren(children, context);
    }
  } 

}
