package medic.ui;

import pilot.Style;
import pilot.Component;

class Header extends Component {

  // Just an example of how you can set styles
  // as attributes:
  @:attribute var rootStyle:Style = css('
    border-bottom: 1px solid #000;
    margin: 0 0 10px 0;
    padding: 0 0 10px 0;
  ');
  @:attribute var title:String;

  override function render() return html(
    <header class={rootStyle.add(css('
      h2 {
        margin: 0;
        padding: 0;
        font-size: 20px;
      }
    '))}>
      <h2>{title}</h2>
    </header>
  );

}
