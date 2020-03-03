package pilot.message;

import pilot.Component;
import pilot.Children;
import pilot.Provider;

class StoreProvider extends Component {

  @:attribute var store:Store<Dynamic, Dynamic>;
  @:attribute var children:Children;

  override function render() return html(
    <Provider id={Store.ID} value={store}>
      {children}
    </Provider>
  );

}
