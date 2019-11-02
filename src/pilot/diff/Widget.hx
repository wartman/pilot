package pilot.diff;

@:allow(pilot.diff.Differ)
class Widget<Real:{}> {
  
  @:noCompletion var _pilot_real:Real;
  @:noCompletion var _pilot_alive:Bool = false;
  @:noCompletion var _pilot_differ:Differ<Real>;

  @:noCompletion final function _pilot_init(differ:Differ<Real>) {
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

  @:noCompletion final function _pilot_update(props:Dynamic) {
    _pilot_setProperties(props);
    _pilot_patch();
  }

  @:noCompletion final function _pilot_patch() {
    if (_pilot_alive == null) {
      throw 'Widget cannot be updated as it was already disposed';
    }
    if (!_pilot_alive) {
      throw 'Widget cannot be updated, as it was never initialized';
    }
    _pilot_differ.patchRoot(_pilot_real, render());
  }

  @:noCompletion function _pilot_setProperties(props:Dynamic) {
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
