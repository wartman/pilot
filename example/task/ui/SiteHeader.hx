package task.ui;

import pilot2.VNode;
import pilot2.Style;
import pilot2.Widget;

class SiteHeader extends Widget {

  override function build():VNode {
    return new VNode({
      name: 'header',
      style: Style.create({

      }),
      children: [
        new VNode({ name: 'h1', children: [ 'Tasks' ] })
      ]
    });
  }

}