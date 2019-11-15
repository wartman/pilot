package todo.ui;

import Pilot.html;
import pilot.RenderResult;
import todo.data.Store;

abstract TodoList(RenderResult) to RenderResult {
  
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
          // note that we don't pass `store` here: instead,
          // it's injected for us by `<StoreProvider /> in a 
          // parent component.
          //
          // This is generally a bad idea, but just for illustration
          // purposes.
          <TodoItem todo={todo} /> 
        </for>
      </ul>
    </div>);
  }

}
