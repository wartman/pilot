package pilot;

typedef WireType<Attrs:{}> = {
  public function __create<Node:{}>(props:Attrs, context:Context<Node>):Wire<Node, Attrs>;
}
