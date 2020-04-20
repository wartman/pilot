package pilot;

class PlaceholderType {
  
  public static function __create<Node>(props:{}, context:Context<Node>):Wire<Node, {}> {
    return new PlaceholderWire(context.engine.createCommentNode(''));
  }

  public static function __hydrate<Node>(node:Node, props:{}, context:Context<Node>):Wire<Node, {}> {
    return new PlaceholderWire(node);
  }

}
