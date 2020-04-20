package pilot;

typedef NativeWireType<Attrs:{}> = WireType<Attrs> & {
  public function __hydrate<Node>(node:Node, props:Attrs, context:Context<Node>):Wire<Node, Attrs>;
}
