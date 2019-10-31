package todo.ui;

import pilot.Component;
import pilot.Template.html;
import todo.data.*;

class TodoItem extends Component {
  
  @:attribute var todo:Todo;
  @:attribute var store:Store;
  @:attribute var editing:Bool = false;

  override function render() return html(
    <li key={todo} id={Std.string(todo.id)} onDblClick={_ -> editing = !editing}>
      <if {editing}>
        <TodoInput 
          value={todo.content}
          save={value -> {
            todo.content = value;
            editing = false;
          }}
        />
      <else>
        <Toggle
          checked={todo.complete}
          onClick={_ -> switch todo.complete {
            case true: store.markPending(todo);
            case false: store.markComplete(todo);
          }}
        />
        <label>{todo.content}</label>
        <button
          class="destroy"
          onClick={_ -> store.removeTodo(todo)}
        >x</button>
      </if>
    </li>
  );

}

// import pilot.Style;
// #if js
//   import js.Browser;
// #end
// import pilot.StatefulWidget;
// import pilot.VNode;
// import pilot.VNode.h;
// import todo.data.Todo;
// import todo.data.Store;

// class TodoItem extends StatefulWidget {

//   @:prop var todo:Todo;
//   @:prop var store:Store;
//   // `editing` is a `@:state`, so it will rerender the view
//   // every time we change it. We could also call `patch()` manually.
//   @:state var editing:Bool = false;

//   override function build():VNode {
//     var style:Style = [
//       Style.create({
//         position: 'relative',
//         'font-size': '24px',
//         'border-bottom': '1px solid #ededed',

//         '&:last-child': {
//           'border-bottom': 'none'
//         },

//         '&.editing': {
//           'border-bottom': 'none',
//           padding: 0,

//           '.edit': {
//             display: 'block',
//             width: '506px',
//             padding: '12px 16px',
//             margin: '0 0 0 43px',
//           }
//         },

//         label: {
//           'word-break':' break-all',
//           padding: '15px 15px 15px 60px',
//           display: 'block',
//           'line-height': '1.2',
//           transition: 'color 0.4s',
//         },

//         '&.completed label': {
//           color: '#d9d9d9',
//           'text-decoration': 'line-through',
//         },

//         '.destroy': {
//           display: 'none',
//           position: 'absolute',
//           top: 0,
//           right: '10px',
//           bottom: 0,
//           width: '40px',
//           height: '40px',
//           margin: 'auto 0',
//           'font-size': '30px',
//           color: '#cc9a9a',
//           'margin-bottom': '11px',
//           transition: 'color 0.2s ease-out',

//           '&:hover': {
//             color: '#af5b5e',
//           },

//           '&:after': {
//             content: '"x"'
//           },

//           media: {
//             query: { maxWidth: '430px' },
//             style: { display: 'block' }
//           },

//         },

//         '&:hover .destroy': {
//           display: 'block'
//         },
//       }),
//       if (todo.complete) Style.create({
//         label: {
//           color: '#d9d9d9',
//           'text-decoration': 'line-through',
//         }
//       }) else null
//     ];

//     return switch editing {
//       case true: h('li', {
//         className: '${style} todo-item editing',
//         key: todo.id,
//         id: 'Todo-${todo.id}',
//         #if js
//           onClick: e -> e.stopPropagation()
//         #end
//       },  [
//         new TodoInput({
//           value: todo.content,
//           #if js
//             onAttached: () -> {
//               function clickOffListener(e) {
//                 editing = false;
//                 Browser.window.removeEventListener('click', clickOffListener);
//               }
//               Browser.window.addEventListener('click', clickOffListener);
//             },
//           #end
//           save: value -> {
//             todo.content = value;
//             editing = false;
//           }
//         })
//       ]);
//       case false: h('li', {
//         key: todo.id,
//         id: 'Todo-${todo.id}',
//         className: '${style} todo-item',
//         #if js
//           onDblClick: e -> editing = true
//         #end
//       }, [
//         // h('input', {
//         //   type: 'checkbox',
//         //   className: 'toggle',
//         //   checked: todo.complete,
//         //   #if js
//         //     onClick: e -> switch todo.complete {
//         //       case true: store.markPending(todo);
//         //       case false: store.markComplete(todo);
//         //     }
//         //   #end
//         // }),
//         new Toggle({
//           type: One,
//           checked: todo.complete,
//           #if js
//             onClick: e -> switch todo.complete {
//               case true: store.markPending(todo);
//               case false: store.markComplete(todo);
//             }
//           #end
//         }),
//         h('label', {}, [ todo.content ]),
//         h('button', {
//           className: 'destroy',
//           #if js
//             onClick: e -> store.removeTodo(todo)
//           #end
//         })
//       ]);
//     }
//   }

// }
