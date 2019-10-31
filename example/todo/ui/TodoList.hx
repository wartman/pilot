package todo.ui;

import pilot.Template.html;
import pilot.PureComponent;
import todo.data.Store;

abstract TodoList(PureComponent) to PureComponent {
  
  public function new(props:{
    store:Store
  }) {
    this = html(<div>
      <Toggle 
        checked={props.store.allSelected}
        id="toggle-all"
        onClick={e -> {
          switch props.store.allSelected {
            case true: props.store.markAllPending();
            default: props.store.markAllComplete();
          }
        }}
      />
      <label for="toggle-all">Toggle All</label>
      <ul>
        <for {todo in props.store.visibleTodos}>
          <TodoItem todo={todo} store={props.store} />
        </for>
      </ul>
    </div>);
  }

}

// import pilot.Style;
// import pilot.VNode;
// import pilot.VNode.h;
// import todo.data.Store;

// abstract TodoList(VNode) to VNode {
  
//   public inline function new(props:{ store:Store }) {
//     var store = props.store;

//     this = h('div', {
//       className: Style.create({
//         position: 'relative',
//         'z-index': 2,
//         'border-top': '1px solid #e6e6e6',
//       })
//     }, [
//       new Toggle({
//         type: All,
//         checked: store.allSelected,
//         id: 'toggle-all',
//         #if js
//           onClick: e -> {
//             switch store.allSelected {
//               case true: store.markAllPending();
//               default: store.markAllComplete();
//             }
//           }
//         #end
//       }),
//       h('label', { htmlFor: 'toggle-all' }, [ 'Toggle All' ]),
//       h('ul', {
//         className: Style.create({
//           margin: 0,
//           padding: 0,
//           'list-style': 'none',
//         })
//       }, [ 
//           for (todo in store.visibleTodos) new TodoItem({
//             todo: todo,
//             store: store
//           }) 
//         ]
//       )
//     ]);
//   }

// }
