package todo.ui;

import pilot.Style;
import pilot.VNode;
import pilot.VNode.h;
import todo.data.Store;
import todo.data.Todo;

abstract SiteHeader(VNode) to VNode {

  public inline function new(props:{ store:Store }) {
    this = h('header', {
      className: 'todo-header'
    }, [
      new VNode({
        name: 'h1',
        style: Style.sheet({
          siteHeader: {
            position: 'absolute',
            top: '-155px',
            width: '100%',
            'font-size': '100px',
            'font-weight': 100,
            'text-align': 'center',
            color: 'rgba(175, 47, 47, 0.15)',
            '-webkit-text-rendering': 'optimizeLegibility',
            '-moz-text-rendering': 'optimizeLegibility',
            'text-rendering': 'optimizeLegibility',
          }
        }),
        children: [ 'todos' ]
      }),
      new TodoInput({
        inputClass: 'new-todo',
        value: '',
        save: value -> props.store.addTodo(new Todo(value))
      }),
    ]);
  }

}
