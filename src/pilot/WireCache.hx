package pilot;

import haxe.ds.Map;

@:structInit
class WireCache<Node> {

  public var types:Map<WireType<Dynamic>, WireRegistry<Node>>;
  public var children:Array<Wire<Node, Dynamic>>;

  public function each(cb:(node:Node)->Void) {
    for (child in children) {
      for (node in child.__getNodes()) cb(node);
    }
  }

}
