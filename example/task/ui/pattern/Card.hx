package task.ui.pattern;

import pilot.*;

class Card extends Widget {
  
  @:prop var children:Children;
  @:prop var hooks:Array<Hook> = [];
  // @:prop @:optional var key:String;
  #if js
    @:prop @:optional var onClick:(e:js.html.Event)->Void;
  #end

  override function build():VNode {
    return new VNode({
      // key: key,
      name: 'div',
      hooks: hooks,
      style: Style.create({
        padding: '1rem',
        borderRadius: '.5rem',
        background: '#cccccc',
        marginBottom: '1rem',
      }),
      props: {
        #if js onClick: onClick #end
      },
      children: children
    });
  }

}
