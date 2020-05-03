package pilot.example;

class StateExample extends Component {
  
  override function render() return html(
    <ExampleContainer title="State Example">
      <ItemsState items={[{
        title: 'One',
        content: 'Two'
      }]}>
        <ItemManager />
        <ItemList />
      </ItemsState>
    </ExampleContainer>
  );

}

class ItemManager extends Component {

  @:attribute(consume) var state:ItemsState;

  override function render() return html(<>
    <input value="" onKeyDown={e -> {
      #if (js && !nodejs)
        var input:js.html.InputElement = cast e.target;
        var keyboardEvent:js.html.KeyboardEvent = cast e;
        if (keyboardEvent.key == 'Enter') {
          
          // todo: fix issue with syncing some node props, like `value`.
          var value = input.value;
          input.value = '';
          
          state.addItem({ title:"Ok", content: value });
          input.blur();
        }
        #end
    }} />
  </>);

}

class ItemList extends Component {

  @:attribute(consume) var state:ItemsState;

  override function render() return html(
    <ul>
      @for (item in state.items) <li>
        <p>{item.content}</p>
        <button onClick={e -> state.removeItem(item)}>Remove</button>
      </li>
    </ul>
  );

}

class ItemsState extends State {

  @:attribute var items:Array<Item>;
  
  @:transition
  public function addItem(item:Item) {
    return { items: items.concat([ item ]) };
  }

  @:transition
  public function removeItem(item:Item) {
    return { items: items.filter(i -> i != item) };
  }

}

typedef Item = {
  title:String,
  content:String
}
