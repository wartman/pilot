package pilot2;

import pilot2.diff.VNode;
import js.html.Node;
import pilot2.target.dom.DomContext;
import pilot2.diff.Differ;

class Renderer {

  static final differ = new Differ(new DomContext());
  
  public static function replace(parent:Node, vn:VNode<Node>) {
    differ.patchRoot(parent, vn);
  }

  public static function mount(parent:Node, vn:VNode<Node>) {
    differ.patch(parent, [ vn ]);
  }
  
}