package pilot.example;

import pilot.Component;

class LocalStateExample extends Component {
  
  @:attribute(state) var clicked:Int = 0;

  override function render() return html(
    <ExampleContainer title="Local State Tracking">
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
