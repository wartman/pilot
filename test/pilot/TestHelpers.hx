package pilot;

import pilot.dom.*;

class TestHelpers {

  public static function render(vn:VNode) {
    var root = new Root(Document.root.createElement('div'));
    root.update(vn);
    return root;
  }

  public static function later(cb:()->Void) {
    var signal = Signal.createVoidSignal();
    signal.addOnce(_ -> cb());
    signal.enqueue(null);
  }

}
