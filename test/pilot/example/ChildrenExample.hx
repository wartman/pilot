package pilot.example;

import pilot.Component;

class ChildrenExample extends Component {

  @:attribute(state) var items:Array<String> = [];

  override function render() return html(
    <ExampleContainer title="Mutable Children">
      <ChildList items={items} />
      <button onClick={_ -> {
        var item = "Thing!";
        items = items.concat([ item ]);
      }}>+</button>
      <button onClick={_ -> items = items.length <= 1
        ? []
        : items.slice(0, items.length - 1)}>-</button>
    </ExampleContainer>
  );

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
