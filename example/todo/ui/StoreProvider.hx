package todo.ui;

import todo.data.Store;
import pilot.Provider;
import pilot.Children;

class StoreProvider extends Provider {
  
  @:attribute var store:Store;
  @:attribute var children:Children;

  override function render() return html(<>
    {children}
  </>);

}
