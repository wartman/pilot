package pilot2.diff;

interface WidgetType<Attrs, Real:{}> {
  public function create(attrs:Attrs):Widget<Real>;
  public function update(widget:Widget<Real>, attrs:Attrs):Void;
}
