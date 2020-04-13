package pilot.example;

import pilot.Component;

class InputExample extends Component {

  @:attribute var value:String = '';
  @:attribute var displayValue:String = '';

  override function render() return html(
    <ExampleContainer title="Input Handling">
      <input value={displayValue} onKeyDown={e -> {
        #if (js && !nodejs)
        var input:js.html.InputElement = cast e.target;
        var keyboardEvent:js.html.KeyboardEvent = cast e;
        if (keyboardEvent.key == 'Enter') {
          
          // todo: fix issue with syncing some node props, like `value`.
          var value = input.value;
          input.value = '';
          
          setValue(value);
          input.blur();
        }
        #end
      }} />
      <span>Current Value: {value}</span>
    </ExampleContainer>
  );
  
  #if (js && !nodejs)
    @:update
    function setValue(value:String) {
      return {
        displayValue: '',
        value: value
      };
    }
  #end

}
