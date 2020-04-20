package pilot;

import haxe.ds.Map;

typedef WireCache<Node> = {
  public var types:Map<WireType<Dynamic>, WireRegistry<Node>>;
  public var children:Array<Wire<Node, Dynamic>>;
}
