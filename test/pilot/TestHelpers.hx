package pilot;

import pilot.dom.*;

class TestHelpers {

  public static function render(vn:VNode) {
    var root = new Root(Document.root.createElement('div'));
    root.update(vn);
    return root;
  }

}
