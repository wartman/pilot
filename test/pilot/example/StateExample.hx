package pilot.example;

import pilot.Component;

class StateExample extends Component {
  
  @:attribute(mutable = true) var clicked:Int = 0;

  override function render() return html(<ExampleContainer title="State Tracking">
    <button onClick={_ -> clicked++}>+</button>
    <button onClick={_ -> if (clicked > 0) clicked--}>-</button>
    <switch {clicked}>
      <case {0}>Never Clicked</case>
      <case {1}>Clicked Once</case>
      <case {i}>Clicked {i} Times</case>
    </switch>
  </ExampleContainer>);

}
