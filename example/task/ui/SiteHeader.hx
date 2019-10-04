package task.ui;

import pilot.*;
import task.data.*;

class SiteHeader extends Widget {

  @:prop var store:Store;
  @:prop.state var isEditing:Bool = false;

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
