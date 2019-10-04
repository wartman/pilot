package task.ui.pattern;

import pilot.*;

class Box extends Widget {

  @:prop @:optional var style:Style;
  @:prop var children:Children;
  #if js
    @:prop @:optional var onClick:(e:js.html.Event)->Void;
  #end

  override function build():VNode {
    return new VNode({
      name: 'div',
      style: style,
      #if js
        props: {
          onClick: onClick
        },
      #end
      children: children
    });
  }

}
