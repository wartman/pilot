package pilot.example;

import pilot.Component;

class EmbeddedCssExample extends Component {

  #if (js && !nodejs)
    override function render() return html(
      <ExampleContainer title="Embedded Css">
        <div class@style-embed={
          background: blue;
          color:white;
          padding: 10px;
        }>Styled!</div>
      </ExampleContainer>
    );
  #else
    override function render() return html(
      <ExampleContainer title="Embedded Css">
        loading...
      </ExampleContainer>
    );
  #end

}
