package task.ui.widget;

import pilot.VNode;
import pilot.Style;
import task.ui.widget.Container;

enum abstract ButtonType(Style) to Style {
  
  var ButtonPrimary = Style.create({

  });

  var ButtonDefault = Style.create({

  });

}

abstract Button(VNode) to VNode  {
  
  public inline function new(props:{
    ?type:ButtonType,
    #if js
      ?onClick:(e:js.html.Event)->Void,
    #end
    children:Array<VNode>
  }) {
    if (props.type == null) props.type = ButtonDefault;
    this = new Container({
      type: ContainerPill,
      style: props.type,
      child: new VNode({
        name: 'button',
        props: {
          #if js
            onClick: props.onClick,
          #end
        },
        children: props.children
      })
    });
  }

}