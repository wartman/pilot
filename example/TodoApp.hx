import pilot.Style;
import todo.ui.App;
import todo.data.Store;
import todo.ui.Color;

class TodoApp {
  
  public static var color = '#4d4d4d';

  public static function main() {
    #if js
      var store = new Store(
        store -> new App({ store: store }),
        js.Browser.document.getElementById('root')
      );
      store.update();
    #else
      var store = new Store(store -> new App({ store: store }));
      store.update();
    #end
  }

}
