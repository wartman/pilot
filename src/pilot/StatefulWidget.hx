package pilot;

#if js
  using pilot.Differ;
#end

@:autoBuild(pilot.macro.WidgetBuilder.build({ stateful: true }))
class StatefulWidget implements Widget {

  function build():VNode {
    return null;
  }

  #if js
  
    @:noCompletion static final _pilot_hasRaf:Bool = js.Syntax.code('window.hasOwnProperty("requestAnimationFrame")');
    @:noCompletion static function _pilot_delay(fn:()->Void) {
      if (_pilot_hasRaf) {
        js.Browser.window.requestAnimationFrame(_ -> fn());
      } else {
        js.Browser.window.setTimeout(fn, 100);
      }
    }
    
    @:noCompletion var _pilot_vnode:VNode;
    @:noCompletion var _pilot_patching:Bool = false;

    public function render():VNode {
      _pilot_vnode = build();
      
      var attachHook = _pilot_vnode.hooks.attach;
      _pilot_vnode.hooks.attach = attachHook == null 
        ? attached
        : vnode -> {
          attachHook(vnode);
          attached(vnode);
        };

      var detachHook = _pilot_vnode.hooks.detach;
      _pilot_vnode.hooks.detach = detachHook == null 
        ? _pilot_detached
        : () -> {
          detachHook();
          _pilot_detached();
        };

      return _pilot_vnode;
    }

    public function patch() {
      if (_pilot_patching) {
        return;
      }
      if (
        _pilot_vnode == null
        || _pilot_vnode.node == null
      ) return;
      _pilot_patching = true;
      _pilot_delay(() -> {
        _pilot_vnode.subPatch(build());
        _pilot_patching = false;
      });
    }

    @:noCompletion final function _pilot_detached() {
      _pilot_vnode = null;
      detached();
    }

    public function attached(vnode:VNode) {
      // noop
    }

    public function detached() {
      // noop
    }

  #else

    public function render():VNode {
      return build();
    }

    public function patch() {
      // noop for now?
    }

  #end

}
