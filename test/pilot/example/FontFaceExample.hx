package pilot.example;

import pilot.Component;

class FontFaceExample extends Component {

  override function render():VNode return html(
    <ExampleContainer title="Font Face">
      <div class={css("
        @global {
          @font-face {
            font-family: 'Open Sans';
            font-style: italic;
            font-weight: 400;
            font-display: swap;
            src: local('Open Sans Italic'), local('OpenSans-Italic'), url('https://fonts.gstatic.com/s/opensans/v18/mem6YaGs126MiZpBA-UFUK0Zdc0.woff2') format('woff2');
          }
        }
      ")}>
        <h2 class={css('
          font-family: "Open Sans", sans-serif;
        ')}>This is Open Sans Italic</h2>
      </div>
    </ExampleContainer>
  );

}