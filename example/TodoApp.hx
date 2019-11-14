import pilot.Dom;
import pilot.Provider;
import todo.data.Store;
import todo.ui.App;

class TodoApp {

  static function main() {
    var root = Dom.getElementById('root');
    var store = new Store(store -> Pilot.html(
      <Provider id="store" value={store}> 
        <App />
      </Provider>
    ), root);
    store.update();

    #if !js
      Sys.print(root.toString());
    #end
  }

}
