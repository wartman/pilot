package medic.ui;

import pilot.Children;
import pilot.Component;

class Container extends Component {

  @:attribute var children:Children;

  override function render() return html(
    <div class@style={
      padding: 10px;
      border-radius: 5px;
      background: rgb( 232, 232, 232 );
      pre {
        background: #666666;
        color: #ffffff;
        border: 1px solid #000;
        padding: 10px;
      }
    }>
      {children}
    </div>
  );

}
