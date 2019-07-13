package todo.ui;

import pilot.Style;
import pilot.VNode;
import pilot.VNode.h;
import todo.data.Store;

abstract App(VNode) to VNode {
  
  inline public function new(props:{ store:Store }) {
    this =  h('div', { id: 'root' }, [
      h('div', { 
        className: Style.create({
          background: '#fff',
          margin: '130px auto 40px auto',
          position: 'relative',
          'box-shadow': '0 2px 4px 0 rgba(0, 0, 0, 0.2), 0 25px 50px 0 rgba(0, 0, 0, 0.1)',
          
          input: {
            '&::input-placeholder': {
              'font-style': 'italic',
              'font-weight': 300,
              color: '#e6e6e6',
            }
          },

          button: {
            margin: 0,
            padding: 0,
            border: 0,
            background: 'none',
            'font-size': '100%',
            'vertical-align': 'baseline',
            'font-family': 'inherit',
            'font-weight': 'inherit',
            color: 'inherit',
            '-webkit-appearance': 'none',
            appearance: 'none',
            '-webkit-font-smoothing': 'antialiased',
            '-moz-osx-font-smoothing': 'grayscale',
          },

        })
      // This following bit is kinda ugly, no?
      //
      // Hmm.
      }, ([
        new SiteHeader({ store: props.store }),
      ]:Array<VNode>).concat( if (props.store.getTodos().length > 0) [
          new TodoList({ store: props.store }),
          new SiteFooter({ store: props.store }) 
      ] else [])),
      h('footer', { 
        className: Style.create({
          margin: '65px auto 0',
          color: '#bfbfbf',
          'font-size': '10px',
          'text-shadow': '0 1px 0 rgba(255, 255, 255, 0.5)',
          'text-align': 'center',
          p: {
            'line-height': 1
          },
          a: {
            color: 'inherit',
            'text-decoration': 'none',
            'font-weight': 400,
            '&:hover': {
              'text-decoration': 'underline',
            },
          },
        }) 
      }, [
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
