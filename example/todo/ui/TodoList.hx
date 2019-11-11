package todo.ui;

import Pilot.html;
import pilot.PureComponent;
import todo.data.Store;

abstract TodoList(PureComponent) to PureComponent {
  
  public function new(props:{
    store:Store
  }) {
    this = html(<div class@style={
      position: relative;
      z-index: 2;
      border-top: 1px solid #e6e6e6;
    }>
      <ToggleAll
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
      <ul class@style={
        margin: 0;
        padding: 0;
        list-style: none;
      }>
        <for {todo in props.store.visibleTodos}>
          <TodoItem todo={todo} store={props.store} />
        </for>
      </ul>
    </div>);
  }

}
