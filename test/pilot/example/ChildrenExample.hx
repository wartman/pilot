package pilot.example;

import pilot.Component;

class ChildrenExample extends Component {

  @:attribute(mutable = true) var items:Array<String> = null;

  override function render() return html(
    <ExampleContainer title="Mutable Children">
      <button onClick={_ -> {
        var item = "Thing!";
        items =  if (items == null) [ item ] else items.concat([ item ]);
      }}>+</button>
      <button onClick={_ -> items = items.length == 1
        ? null
        : items.slice(0, items.length - 1)}>-</button>
      <ul>
        <for {item in items}>
          <li>{item}</li>
        <else>
          <li>No items</li>
        </for>
      </ul>
    </ExampleContainer>
  );

}
