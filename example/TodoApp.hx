import pilot.Style;
import todo.ui.App;
import todo.data.Store;
import todo.ui.Color;

class TodoApp {
  
  public static var color = '#4d4d4d';

  public static function main() {
    Style.global({ 
      'html, body': {
        margin: 0,
        padding: 0,
      },
      body: {
        font: '14px "Helvetica Neue", Helvetica, Arial, sans-serif',
        'line-height': '1.4em',
        background: Color.secondary,
        color: Color.primary,
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
