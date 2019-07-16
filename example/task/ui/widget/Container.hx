package task.ui.widget;

import pilot.Style;
import pilot.VNode;
import pilot.StyledWidget;

enum abstract ContainerType(Style) to Style {
  
  var ContainerRounded = Style.create({
    borderRadius: '.5em'
  });

  var ContainerPill = Style.create({
    borderRadius: '1em',
    height: '2em',
    lineHeight: '2em',
    paddingTop: 0,
    paddingBottom: 0,
  });

  var ContainerDefault = Style.create({
    // noop
  });

}

enum abstract ContainerBackground(Style) to Style {
  
  var BgPrimary = Style.create({
    background: '#e2e2e2',
  });

  var BgOffset = Style.create({

  });

  var BgDefault = Style.create({

  });

}

abstract Container(VNode) to VNode {
  
  public inline function new(props:{
    type:ContainerType,
    ?background:ContainerBackground,
    ?style:Style,
    child:VNode
  }) {
    this = new StyledWidget({
      compose: [ 
        props.type, 
        props.style,
        props.background,
        Style.create({
          padding: '0 .5em',
        })
      ],
      child: props.child
    });
  }

}
