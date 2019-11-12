package pilot.core;

typedef NodeType<Attrs, Real:{}> = {
  public function _pilot_create(attrs:Attrs, context:Context):Wire<Attrs, Real>;
}
