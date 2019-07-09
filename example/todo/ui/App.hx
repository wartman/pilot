package todo.ui;

import pilot.VNode;
import pilot.VNode.h;
import todo.data.Store;

abstract App(VNode) to VNode {
  
  inline public function new(props:{ store:Store }) {
    this = h('div', { id: 'root' }, [
      h('div', { className: 'todoapp' }, [
        new SiteHeader({ store: props.store }),
        new TodoList({ store: props.store }),
        new SiteFooter({ store: props.store })
      ]),
      h('footer', { className: 'footer' }, [
        h('p', {}, [ 'Double-click to edit a todo.' ]),
        h('p', {}, [ 
          'Written by ', h('a', { href: 'https://github.com/wartman' }, [ 'wartman' ])
        ]),
        h('p', {}, [
          'Part of ', h('a', { href: 'http://todomvc.com' }, [ 'TodoMVC' ])
        ])
      ])
    ]);
  }

}
