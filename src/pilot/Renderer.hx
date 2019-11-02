package pilot;

import pilot.diff.VNode;
import pilot.diff.Differ;

class Renderer {

  static final differ = new Differ(new Context());
  
  public static function replace(parent:Node, vn:VNode<Node>) {
    differ.patchRoot(parent, vn);
  }

  public static function mount(parent:Node, vn:VNode<Node>) {
    differ.patch(parent, [ vn ]);
  }
  
}
