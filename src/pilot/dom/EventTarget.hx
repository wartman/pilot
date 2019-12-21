package pilot.dom;

import haxe.DynamicAccess;

typedef EventHandler = (e:Event)->Void; 

class EventTarget {

  final eventHandlers:DynamicAccess<Array<EventHandler>> = {};
  
  public function addEventListener(type:String, handler:EventHandler) {
    type = type.toLowerCase();
    if (!eventHandlers.exists(type)) {
      eventHandlers.set(type, []);
    }
    eventHandlers.get(type).push(handler);
  }

  public function removeEventListener(type:String, handler:EventHandler) {
    type = type.toLowerCase();
    if (eventHandlers.exists(type)) {
      eventHandlers.get(type).remove(handler);
    }
  }

  public function dispatchEvent(event:Event) {
    throw 'not implemented';
  }

}
