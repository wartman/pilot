package pilot.example;

import pilot.Component;

class StateExample extends Component {
  
  @:attribute(mutable = true) var clicked:Int = 0;

  override function render() return html(
    <ExampleContainer title="State Tracking">
      <div>
        { switch clicked {
          case 0: <>Never Clicked</>;
          case 1: <>Clicked Once</>;
          case i: <>Clicked {i} Times</>;
        } }
      </div>
      <div>
        <button onClick={_ -> clicked++}>+</button>
        <button onClick={_ -> if (clicked > 0) clicked--}>-</button>
      </div>
    </ExampleContainer>
  );

}
