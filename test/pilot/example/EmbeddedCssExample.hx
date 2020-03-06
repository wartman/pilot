package pilot.example;

import pilot.Component;

class EmbeddedCssExample extends Component {

  static final COLOR_BLUE = 'blue';
  static final COLOR_WHITE = 'white';

  override function render() return html(
    <ExampleContainer title="Embedded Css">
      <div class={css('
        background: ${EmbeddedCssExample.COLOR_BLUE};
        color:${EmbeddedCssExample.COLOR_WHITE};
        padding: 10px;
        margin-left: -40px;
        width: calc(100% + 40px);
      ', { embed: true })}>Styled!</div>
    </ExampleContainer>
  );

}
