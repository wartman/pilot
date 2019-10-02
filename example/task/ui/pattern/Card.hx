package task.ui.pattern;

import pilot2.*;

class Card extends Widget {
  
  @:prop var children:Children;

  override function build():VNode {
    return new VNode({
      name: 'div',
      style: Style.create({
        padding: '1rem',
        borderRadius: '.5rem',
      }),
      children: children
    });
  }

}