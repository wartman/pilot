import pilot.Style;
import todo.ui.App;
import todo.data.Store;

class TodoApp {
  
  public static function main() {
    Style.global({
      'html, body': {
        margin: 0,
        padding: 0,
      },
      body: {
        font: '14px "Helvetica Neue", Helvetica, Arial, sans-serif',
        'line-height': '1.4em',
        background: '#f5f5f5',
        color: '#4d4d4d',
        'min-width': '230px',
        'max-width': '550px',
        margin: '0 auto',
        '-webkit-font-smoothing': 'antialiased',
        '-moz-osx-font-smoothing': 'grayscale',
        'font-weight': 300,
      },
      ':focus': {
        outline: 0,
      },
    });
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
