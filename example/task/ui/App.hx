package task.ui;

import pilot2.*;
import task.data.Store;

class App extends Widget {
  
  @:prop var store:Store;
  @:style var root = {
    display: 'flex',
    flexDirection: 'column',
    maxWidth: '900px', 
    margin: '0 auto',
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
      props: { id: 'root' },
      children: [
        new SiteHeader({ store: store }),
        new TaskList({ store: store })
      ]
    });
  }

}
