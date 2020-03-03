package pilot.message;

import haxe.ds.Option;
import pilot.Signal;

using Lambda;

@:allow(pilot.message.Message)
@:allow(pilot.message.StoreProvider)
class Store<Action, Data> {

  static final ID:String = '__pilot_message_Store__';

  final onUpdate:Signal<Data> = new Signal();
  final updaters:Array<MessageUpdate<Action, Data>> = [];
  var data:Data;
  var isDispatching:Bool = false;
  
  public function new(data) {
    this.data = data;
  }

  function update(action:Action):Option<Data> {
    var nextData = data;
    for (updater in updaters) {
      var delta = updater.__updateData(action, nextData);
      if (delta != null) {
        // todo: updaters should be able to handle slices of
        // data :/.
        nextData = delta;
      }
    }
    return if (nextData != data)
      Some(nextData);
    else
      None;
  }

  public function addUpdater(updater:MessageUpdate<Action, Data>) {
    if (!hasUpdater(updater)) updaters.push(updater);
  }

  public function hasUpdater(updater:MessageUpdate<Action, Data>) {
    return updaters.has(updater);
  }

  public final function dispatch(action:Action) {
    isDispatching = true;
    switch update(action) {
      case Some(v): 
        data = v;
        onUpdate.dispatch(data);
      case None:
    }
    isDispatching = false;
  }

  public function subscribe(listener:(data:Data)->Void) {
    if (isDispatching) {
      throw 'You cannot subscribe to a Store while it is dispatching. '
        + 'Subscribe using a Message or via Store#subscribe.';
    }
    return onUpdate.add(listener);
  }

  public function get():Data {
    return data;
  }

}
