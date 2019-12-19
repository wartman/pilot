package pilot.example;

import pilot.Component;

class InputExample extends Component {

  @:attribute(mutable = true) var value:String = '';

  override function render() return html(<ExampleContainer title="Input Handling">
    <input value={value} onKeyDown={e -> {
      #if (js && !nodejs)
      var input:js.html.InputElement = cast e.target;
      var keyboardEvent:js.html.KeyboardEvent = cast e;
      if (keyboardEvent.key == 'Enter') {
        value = input.value;
        input.blur();
      }
      #end
    }} />
    <span>Current Value: {value}</span>
  </ExampleContainer>);

}
