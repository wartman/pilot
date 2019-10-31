package pilot.diff;

@:allow(pilot.diff.Differ, pilot.diff.WidgetType)
class Widget<Real:{}> {
  
  var _pilot_real:Real;
  var _pilot_alive:Bool = false;
  var _pilot_differ:Differ<Real>;

  function _pilot_init(differ:Differ<Real>) {
    if (_pilot_alive == null) {
      throw 'Widget cannot be used as it was already disposed';
    }
    if (_pilot_alive) {
      throw 'Widget is already in use';
    }
    _pilot_alive = true;
    _pilot_differ = differ;
    _pilot_real = _pilot_differ.patchRoot(null, render());
  }

  function _pilot_update() {
    if (_pilot_alive == null) {
      throw 'Widget cannot be updated as it was already disposed';
    }
    if (!_pilot_alive) {
      throw 'Widget cannot be updated, as it was never initialized';
    }
    _pilot_differ.patchRoot(_pilot_real, render());
  }

  function _pilot_setProperties(props:Dynamic) {
    // noop
  }

  public function render():VNode<Real> {
    return null;
  }

  public function dispose() {
    _pilot_alive = null;
    _pilot_real = null;
    _pilot_differ = null;
  }

}
