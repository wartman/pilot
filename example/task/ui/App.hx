package task.ui;

import pilot.*;
import task.data.Store;
import task.ui.pattern.*;

class App extends Widget {
  
  @:prop var store:Store;
  @:style var root = {
    display: 'flex',
    flexDirection: 'column',
    maxWidth: '900px',
    width: '100%',
    margin: '0 auto',
  };
  @:style.global var glob = {
    'html, body': {
      margin: 0,
      padding: 0,
      fontFamily: 'sans-serif'
    }
  };

  override function build():VNode {
    return new VNode({
      name: 'div',
      style: root,
      props: { id: 'root' },
      children: [
        new PortalTarget({ id: 'overlay' }),
        new SiteHeader({ store: store }),
        new TaskList({ store: store }),
      ]
    });
  }

}
