import pilot.Dom;
import todo.data.Store;
import todo.ui.App;
import todo.ui.StoreProvider;

class TodoApp {

  static function main() {
    var testValues = [ 'a', 'b', 'c' ];
    var root = Dom.getElementById('root');
    var store = new Store(store -> Pilot.html(
      <StoreProvider store={store}> 
        <App />

        <div>
          <h2>These are some random tests:</h2>

          <svg xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="0 0 30 30">
            <g transform="translate(-562.58 -31.105)">
              <path style="color-rendering:auto;text-decoration-color:#000000;color:#000000;shape-rendering:auto;solid-color:#000000;text-decoration-line:none;fill:#1a1a1a;mix-blend-mode:normal;block-progression:tb;text-indent:0;image-rendering:auto;white-space:normal;text-decoration-style:solid;isolation:auto;text-transform:none" d="m576 41.877-4.3008 4.2285 4.3008 4.2285 1.752-1.7832-2.4863-2.4453 2.4863-2.4453-1.752-1.7832zm5.7109 0-4.3008 4.2285 4.3008 4.2285 1.7539-1.7832-2.4883-2.4453 2.4883-2.4453-1.7539-1.7832z"/>
            </g>
          </svg>

          <for {value in testValues}>{value}</for>
        </div>
      </StoreProvider>
    ), root);
    store.update();

    #if !js
      Sys.print(root.toString());
    #end
  }

}
