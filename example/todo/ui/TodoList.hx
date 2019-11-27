package todo.ui;

import pilot.Component;
import todo.data.*;

class TodoList extends Component {
  
  @:attribute var store:Store;
  @:attribute var todos:Array<Todo>;

  override function render() return html(
    <div class@style={
      position: relative;
      z-index: 2;
      border-top: 1px solid #e6e6e6;
    }>
      <ToggleAll
        checked={store.allSelected}
        id="toggle-all"
        onClick={e -> {
          switch store.allSelected {
            case true: store.markAllPending();
            default: store.markAllComplete();
          }
        }}
      />
      <label for="toggle-all">Toggle All</label>
      <ul class@style={
        margin: 0;
        padding: 0;
        list-style: none;
      }>
        <for {todo in todos}>
          // note that we don't pass `store` here: instead,
          // it's injected for us by `<StoreProvider /> in a 
          // parent component.
          <TodoItem todo={todo} /> 
        </for>
      </ul>
    </div>
  );

  @:init public function startup() {
    trace('This will be logged before the component is first rendered');
  }

  @:dispose public function removed() {
    trace('This will be logged when the component is removed.');
  }

}
