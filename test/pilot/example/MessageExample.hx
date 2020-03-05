package pilot.example;

import pilot.message.*;
import pilot.Component;

using Lambda;

enum Action {
  None;
  AddItem(content:String);
  UpdateItem(id:Int, content:String);
  RemoveItem(id:Int);
}

typedef Item = {
  id:Int,
  content:String
}

typedef Data = {
  ids:Int,
  items: Array<Item>
};

@:update(switch message {
  case None: null;
  case AddItem(content): 
    {
      ids: data.ids + 1,
      items: data.items.concat([ { 
        id: data.ids + 1,
        content: content
      } ])
    };
  case UpdateItem(id, content): 
    var item = data.items.find(d -> d.id == id);
    if (item == null) {
      throw 'No item with the id ${id} exists';
    }
    item.content = content;
    return data;
  case RemoveItem(id):
    {
      ids: data.ids,
      items: data.items.filter(i -> i.id != id)
    };
})
class ItemsManager extends Message<Action, Data> {

  @:state var items:Array<Item>;

  @:send
  public function addItem(content):Action {
    return AddItem(content);
  }

  @:send
  public function removeItem(item:Item):Action {
    return RemoveItem(item.id);
  }

  @:send
  public function updateItem(item:Item, content:String):Action {
    return UpdateItem(item.id, content);
  }

}

class MessageExample extends Component {
  
  override function render() {
    var store:Store<Action, Data> = new Store({
      ids: 0,
      items: []
    });
    return html(
      <ExampleContainer title="Message Test">
        <StoreProvider store={store}>
          <ItemList />  
        </StoreProvider>
      </ExampleContainer>
    );
  }

}

class ItemList extends Component {

  @:attribute var manager:ItemsManager = new ItemsManager();

  override function render() return html(<ul>
    <Editor onSubmit={manager.addItem} />
    @for (item in manager.items) <li>
      <p>{item.id}</p>
      <p>{item.content}</p>
      <button onClick={_ -> manager.removeItem(item)}>X</button>
    </li>
  </ul>);

}

class Editor extends Component {

  @:attribute var displayValue:String = '';
  @:attribute var onSubmit:(value:String)->Void;
  var value:String = '';

  override function render() return html(<div>
    <input value={displayValue} onKeyDown={e -> {
      #if (js && !nodejs)
      var input:js.html.InputElement = cast e.target;
      var keyboardEvent:js.html.KeyboardEvent = cast e;
      if (keyboardEvent.key == 'Enter') {
        onSubmit(input.value);
        clear();
        input.blur();
      } else {
        value = input.value;
      }
      #end
    }} />
    <button onClick={_ -> {
      onSubmit(value);
      clear();
    }}>Add</button>
  </div>);
  
  @:update
  function clear() {
    value = '';
    return {
      displayValue: ''
    };
  }

}
