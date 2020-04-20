package pilot;

class TextType {

  public static function __create<Node>(props:{ content:String }, context:Context<Node>):Wire<Node, { content:String }> {
    return new TextWire(context.engine.createTextNode(props.content));
  }

  public static function __hydrate<Node>(node:Node, props:{ content:String }, context:Context<Node>):Wire<Node, { content:String }> {
    return new TextWire(node);
  }

}
