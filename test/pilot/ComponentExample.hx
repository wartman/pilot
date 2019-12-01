package pilot;

import medic.ui.*;
import pilot.example.*;

class ComponentExample extends Component {

  override function render() return html(<Container>
    <Header title="Interactive Component Examples" />
    <ul>
      <StateExample />
      <InputExample />
      <ChildrenExample />
      <SvgExample />
    </ul>
  </Container>);

}
