package todo.ui;

import pilot.Component;
import pilot.Children;
import pilot.Provider;
import todo.data.Store;

class StoreProvider extends Component {
  
  public static final ID = 'StoreProvider';

  @:attribute var store:Store;
  @:attribute var children:Children;

  override function render() return html(
    <Provider id={ID} value={store}>
      {children}
    </Provider>
  );

}