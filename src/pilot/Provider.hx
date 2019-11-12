package pilot;

import haxe.DynamicAccess;
import pilot.core.Context;
import pilot.core.Component;

@:coreComponent
class Provider extends Component<RealNode> {
  
  var _pilot_subContext:Context;

  function _pilot_setSubContext(props:DynamicAccess<Dynamic>, context:Context) {
    _pilot_subContext = context.copy();
    for (key => value in props) {
      _pilot_subContext.set(key, value);
    }
  }

  override function _pilot_update(attrs:Dynamic, context:Context) {
    _pilot_context = context;
    if (_pilot_wire == null && componentShouldRender(attrs)) {
      _pilot_setSubContext(_pilot_setProperties(attrs, context), context);
      _pilot_doInitialRender(render(), _pilot_subContext);
    } else if (componentShouldRender(attrs)) {
      _pilot_setSubContext(_pilot_setProperties(attrs, context), context);
      _pilot_doDiffRender(render(), _pilot_subContext);
    }
  }

}

