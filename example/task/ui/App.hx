package task.ui;

import pilot2.VNode;
import pilot2.Widget;
import task.data.Store;

class App extends Widget {
  
  @:prop var store:Store;
  @:style var root = {
    display: 'flex',
    maxWidth: '900px', 
  };
  @:style.global var glob = {
    'html, body': {
      margin: 0,
      padding: 0,
    }
  };

  override function build():VNode {
    return new VNode({
      name: 'div',
      style: root,
      // props: { id: 'root' },
      children: [
        new SiteHeader({ store: store }),
        new VNode({
          name: 'div',
          children: [ for (task in store.getFilteredTasks()) 
            new TaskItem({
              store: store,
              task: task
            }) 
          ]
        })
      ]
    });
  }

}