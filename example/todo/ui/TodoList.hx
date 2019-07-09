package todo.ui;

import pilot.VNode;
import pilot.VNode.h;
import todo.data.Store;

abstract TodoList(VNode) to VNode {
  
  public inline function new(props:{ store:Store }) {
    var store = props.store;
    this = h('ul', {
      className: 'todo-list'
    }, if (store.visibleTodos.length > 0) [ 
        for (todo in store.visibleTodos) new TodoItem({
          todo: todo,
          store: store
        }) 
      ] else [
        h('li', { className: 'todo-item todo-item--none' }, [
          h('label', {}, [
            switch store.filter {
              case VisibleAll: 'No Items';
              case VisibleCompleted: 'No Completed Items';
              case VisiblePending: 'No Pending Items';
            }
          ])
        ])
      ]
    );
  }

}
