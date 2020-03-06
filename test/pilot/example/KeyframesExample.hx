package pilot.example;

import pilot.Component;

class KeyframesExample extends Component {
  
  override function render() return html(
    <ExampleContainer title="Keyframes">
      <div class={css('
        display: relative;
        height: 150px;
        width: 100%;
      ')}>
        <div class={css('
          position: relative;
          border: 16px solid #f3f3f3;
          border-radius: 50%;
          border-top: 16px solid #3498db;
          width: 70px;
          height: 70px;
          left:50%;
          top:50%;
          animation: spin 2s linear infinite;
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
        ')} />
      </div>
    </ExampleContainer>
  );

}
