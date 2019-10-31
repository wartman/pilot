package pilot.diff;

interface NodeType<Attrs, Real:{}> {
  public function create(attrs:Attrs):Real;
  public function update(node:Real, oldAttrs:Attrs, newAttrs:Attrs):Void;
}
