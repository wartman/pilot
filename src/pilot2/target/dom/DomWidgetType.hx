package pilot2.target.dom;

import js.html.Node;
import pilot2.diff.*;

class DomWidgetType<Attrs> implements WidgetType<Attrs, Node> {
  
  final factory:(attrs:Attrs)->Widget<Node>;

  public function new(factory) {
    this.factory = factory;
  }

  public function create(attrs:Attrs):Widget<Node> {
    return factory(attrs);
  }

  public function update(widget:Widget<Node>, attrs:Attrs):Void {
    widget._pilot_setProperties(attrs);
    widget._pilot_update();
  }

}
