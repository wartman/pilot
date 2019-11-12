package pilot;

import pilot.core.VNode;
import pilot.core.Context;
import pilot.core.WireBase;
import pilot.core.Wire;

class Fragment extends WireBase<Dynamic, RealNode> {
  
  public static function _pilot_create(attrs:Dynamic, context:Context):Wire<Dynamic, RealNode> {
    return new Fragment();
  }

  var parent:Wire<Dynamic, RealNode>;
  var real:RealNode;
  var later:()->Void;

  public function new() {}

  override function _pilot_getReal() {
    return real;
  }
  
  override function _pilot_insertInto(parent:Wire<Dynamic, RealNode>) {
    this.parent = parent;
    real = parent._pilot_getReal();
    if (later != null) {
      later();
      later = null;
    }
  }

  override function _pilot_appendChildReal(child:RealNode) {
    _pilot_getReal().appendChild(child);
  }

  override function _pilot_removeChildReal(child:RealNode) {
    _pilot_getReal().removeChild(child);
  }

  override function _pilot_removeReal() {
    // noop
  }

  override function _pilot_update(newAttrs:Dynamic, context:Context) {
    // noop
  }

  override function _pilot_removeFrom(parent:Wire<Dynamic, RealNode>) {
    for (c in childList) c._pilot_removeFrom(parent);
    _pilot_dispose();
  }

  override function _pilot_dispose() {
    later = null;
    parent = null;
    types = null;
    childList = null;
  }

  override function _pilot_updateChildren(children:Array<VNode<RealNode>>, context:Context) {
    if (parent != null) {
      super._pilot_updateChildren(children, context);
    } else {
      later = () -> _pilot_updateChildren(children, context);
    }
  } 

}
