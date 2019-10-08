package task.ui.pattern;

import pilot.*;

class Overlay extends Widget {
  
  @:prop var child:VNode;
  #if js
    @:prop var requestClose:()->Void;
  #end

  override function build():VNode {
    return new VNode({
      name: 'div',
      style: Style.create({
        display: 'flex',
        flexWrap: 'wrap',
        overflowY: 'scroll',
        position: 'fixed',
        top: 0,
        bottom: 0,
        right: 0,
        left: 0,
        background: 'rgba(0,0,0,0.4)'
      }),
      #if js
        props: {
          onClick: _ -> requestClose()
        },
      #end
      children: [ child ]
    });
  }

}
