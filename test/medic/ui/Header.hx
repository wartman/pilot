package medic.ui;

import pilot.Component;

class Header extends Component {

  @:attribute var title:String;

  override function render() return html(
    <header class@style={
      border-bottom: 1px solid #000;
      margin: 0 0 10px 0;
      padding: 0 0 10px 0;
      h2 {
        margin: 0;
        padding: 0;
        font-size: 20px;
      }
    }>
      <h2>{title}</h2>
    </header>
  );

}