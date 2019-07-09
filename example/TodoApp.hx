import todo.ui.App;
import todo.data.Store;

class TodoApp {
  
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
