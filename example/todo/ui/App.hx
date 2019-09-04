package todo.ui;

import pilot.Style;
import pilot.VNode;
import pilot.VNode.h;
import todo.data.Store;

abstract App(VNode) to VNode {
  
  public function new(props:{ store:Store }) {
    this =  h('div', { id: 'root' }, [
      h('div', { 
        className: Style.create('todo-app' => {
          background: '#fff',
          margin: '130px auto 40px auto',
          position: 'relative',
          boxShadow: '0 2px 4px 0 rgba(0, 0, 0, 0.2), 0 25px 50px 0 rgba(0, 0, 0, 0.1)',
          
          input: {
            '&::input-placeholder': {
              fontStyle: 'italic',
              fontWeight: 300,
              color: '#e6e6e6',
            }
          },

          button: {
            margin: 0,
            padding: 0,
            border: 0,
            background: 'none',
            fontSize: '100%',
            verticalAlign: 'baseline',
            fontFamily: 'inherit',
            fontWeight: 'inherit',
            color: 'inherit',
            appearance: 'none',
            '-webkit-appearance': 'none',
            '-webkit-font-smoothing': 'antialiased',
            '-moz-osx-font-smoothing': 'grayscale',
          },

        }) + Style.global('global' => { 
          'html, body': {
            margin: 0,
            padding: 0,
          },
          body: {
            font: '14px "Helvetica Neue", Helvetica, Arial, sans-serif',
            'line-height': '1.4em',
            background: Color.secondary,
            color: Color.primary,
            'min-width': '230px',
            'max-width': '550px',
            margin: '0 auto',
            '-webkit-font-smoothing': 'antialiased',
            '-moz-osx-font-smoothing': 'grayscale',
            'font-weight': 300,
          },
          ':focus': {
            outline: 0,
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
        className: Style.create('todo-app-footer' => {
          margin: '65px auto 0',
          color: '#bfbfbf',
          fontSize: '10px',
          textShadow: '0 1px 0 rgba(255, 255, 255, 0.5)',
          textAlign: 'center',
          p: {
            lineHeight: 1
          },
          a: {
            color: 'inherit',
            textDecoration: 'none',
            fontWeight: 400,
            '&:hover': {
              textDecoration: 'underline',
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
