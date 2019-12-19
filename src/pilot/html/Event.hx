package pilot.html;

#if (js && !nodejs)

typedef Event = js.html.Event;

#else

@:allow(pilot.html.EventTarget)
class Event {

  final type:String;
  public var defaultPrevented:Bool;
  var end:Bool = false;
  var stop:Bool = false;
  var cancelable:Bool = true;
  var bubbles:Bool = true;
  public var target:EventTarget;
  public var currentTarget:EventTarget;

  public function new(type, ?options:{
    ?bubbles:Bool,
    ?cancelable:Bool
  }) {
    this.type = type;
    if (options != null) {
      cancelable = options.cancelable;
      bubbles = options.bubbles;
    }
  }

  public function stopPropagation() {
    stop = true;
  }

  public function stopImmediatePropagation() {
    end = stop = true;
  }

  public function preventDefault() {
    defaultPrevented = true;
  }

}

#end
