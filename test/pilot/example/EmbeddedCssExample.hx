package pilot.example;

import pilot.Component;

class EmbeddedCssExample extends Component {

  override function render() return html(
    <ExampleContainer title="Embedded Css">
      <div class@style-embed={
        background: blue;
        color:white;
        padding: 10px;
      }>Styled!</div>
    </ExampleContainer>
  );

}
