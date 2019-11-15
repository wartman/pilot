import pilot.Dom;
import todo.data.Store;
import todo.ui.App;
import todo.ui.StoreProvider;

class TodoApp {

  static function main() {
    var root = Dom.getElementById('root');
    var store = new Store(store -> Pilot.html(
      <StoreProvider store={store}> 
        <App />
      </StoreProvider>
    ), root);
    store.update();

    #if !js
      Sys.print(root.toString());
    #end
  }

}
