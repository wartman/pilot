package todo.ui;

import pilot.StatelessWidget;
import pilot.VNode;
import pilot.VNode.h;
import todo.data.Store;
import todo.data.VisibleTodos;

class SiteFooter extends StatelessWidget {

  @:prop var store:Store;

  override function build():VNode {
    return h('footer', {
      className: 'footer'
    }, [
      h('span', { className: 'todo-count' }, [
        remaining()
      ]),
      h('ul', { className: 'filters' }, [
        h('li', {}, [
          h('a', { 
            href: '#all',
            className: store.filter == VisibleAll ? 'filter selected' : 'filter',
            #if js
              onClick: e -> setFilter(e, VisibleAll)
            #end
          }, [ 'All' ])
        ]),
        h('li', {}, [
          h('a', { 
            href: '#pending',
            className: store.filter == VisiblePending ? 'filter selected' : 'filter',
            #if js
              onClick: e -> setFilter(e, VisiblePending)
            #end
          }, [ 'Pending' ])
        ]),
        h('li', {}, [
          h('a', { 
            href: '#pending',
            className: store.filter == VisibleCompleted ? 'filter selected' : 'filter',
            #if js
              onClick: e -> setFilter(e, VisibleCompleted)
            #end
          }, [ 'Complete' ])
        ])
      ])
    ]);
  }

  function remaining():VNode {
    return switch store.remainingTodos {
      case 0: 'No items left';
      case 1: '1 item left';
      case remaining: '${remaining} items left';
    }
  }

  #if js

    function setFilter(e:js.html.Event, filter:VisibleTodos) {
      e.preventDefault();
      store.setFilter(filter);
    }

  #end

}
