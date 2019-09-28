package pilot2;

@:allow(pilot2.WidgetState)
interface WidgetLike extends Renderable {
  private function build():VNode;
}
