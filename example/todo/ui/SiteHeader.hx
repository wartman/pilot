package todo.ui;

import pilot.VNode;
import pilot.VNode.h;
import todo.data.Store;
import todo.data.Todo;

abstract SiteHeader(VNode) to VNode {

  public inline function new(props:{ store:Store }) {
    this = h('header', {
      className: 'todo-header'
    }, [
      h('h1', {}, [ 'Todo' ]),
      new TodoInput({
        inputClass: 'new-todo',
        value: '',
        save: value -> props.store.addTodo(new Todo(value))
      }),
    ]);
  }

}
