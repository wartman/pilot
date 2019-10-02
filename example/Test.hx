import pilot2.VNode;
import task.ui.App;
import task.data.Store;

class Test {

  static function main() {
    var store = new Store([], store -> new VNode({
      name: 'div',
      props: { id: 'root' },
      children: [ new App({ store: store }) ]
    }));
    #if js
      store.mount(js.Browser.document.getElementById('root'));
    #else
      store.render();
    #end
  }

}
