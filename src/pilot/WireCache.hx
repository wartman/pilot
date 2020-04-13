package pilot;

import haxe.ds.Map;

@:structInit
class WireCache<Node:{}> {

  public var types:Map<WireType<Dynamic>, WireRegistry<Node>>;
  public var children:Array<Wire<Node, Dynamic>>;

  public function each(cb:(node:Node)->Void) {
    for (child in children) {
      for (node in child.__getNodes()) cb(node);
    }
    // function inner(children:Array<Wire<Dynamic, Dynamic>>) {
    //   for (wire in children) switch Std.downcast(wire, Component) {
    //     case null: switch Std.downcast(wire, NodeWire) {
    //       case null: switch Std.downcast(wire, TextWire) {
    //         case null: throw 'assert';
    //         case textWire: cb(@:privateAccess textWire.node);
    //       }
    //       case nodeWire: cb(@:privateAccess nodeWire.node);
    //     }
    //     case comp:
    //       inner(cast @:privateAccess comp.__cache.children);
    //   }
    // }
    // inner(children);
  }

}
