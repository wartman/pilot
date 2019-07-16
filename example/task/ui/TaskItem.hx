package task.ui;

import pilot.VNode;
import pilot.StatelessWidget;
import task.ui.widget.Container;

class TaskItem extends StatelessWidget {
  
  override function build():VNode {
    return new Container({
      type: ContainerRounded,
      background: BgOffset,
      child: new VNode({
        name: 'div',
        props: {},
        children: []
      })
    });
  }

}
