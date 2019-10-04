import task.ui.App;
import task.data.Store;

class Test {

  static function main() {
    var store = new Store([], store -> new App({ store: store }));
    #if js
      store.mount(js.Browser.document.getElementById('root'));
    #else
      store.render();
    #end
  }

}
