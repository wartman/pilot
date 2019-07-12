package todo.ui;

import pilot.Style;
import pilot.VNode;
import pilot.VNode.h;
import todo.data.Store;

abstract TodoList(VNode) to VNode {
  
  public inline function new(props:{ store:Store }) {
    var store = props.store;
    var cls = Style.create({
      margin: 0,
      padding: 0,
      'list-style': 'none',
    });

    this = h('ul', {
      className: cls
    }, [ 
        for (todo in store.visibleTodos) new TodoItem({
          todo: todo,
          store: store
        }) 
      ]
    );
  }

}
