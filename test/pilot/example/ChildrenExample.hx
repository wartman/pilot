package pilot.example;

import pilot.Component;

class ChildrenExample extends Component {

  @:attribute var items:Array<String> = [];

  override function render() return html(
    <ExampleContainer title="Mutable Children">
      <ChildList items={items} />
      <button onClick={_ -> addItem('thing!')}>+</button>
      <button onClick={_ -> removeItem()}>-</button>
    </ExampleContainer>
  );

  @:update
  public function addItem(item:String) {
    return {
      items: items.concat([ item ])
    };
  }

  @:update
  public function removeItem() {
    return {
      items: items.length <= 1
        ? []
        : items.slice(0, items.length - 1)
    };
  }

}

class ChildList extends Component {

  @:attribute var items:Array<String>;

  override function render() {
    if (items.length == 0) return null;
    return html(<ul>
      { [ for (item in items) <li>{item}</li> ] }
    </ul>);
  }

}
