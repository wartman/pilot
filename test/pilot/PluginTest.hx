package pilot;

import pilot.Signal;

using Medic;
using pilot.TestHelpers;

class PluginTest implements TestCase {

  public function new() {}

  @test('Plugins are conencted correctly')
  @async
  public function testConnection(done) {
    var plugin = new IncrementingPlugin();
    var root = new Root(Pilot.document.createElement('div'));
    plugin.changed.equals(0);
    root.update(Pilot.html(<PluginTester plugin={plugin} />));
    TestHelpers.later(() -> {
      plugin.changed.equals(1);
      done();
    });
  }

}

class IncrementingPlugin implements Plugin {

  var __effect:SignalSubscription<Component>;
  public var changed:Int = 0;

  public function new() {}

  public function __connect(component:Component) {
    __effect = component.__onEffect.add(c -> {
      changed++;
    });
  }

  public function __disconnect(component:Component) {
    __effect.cancel();
  }

}

class PluginTester extends Component {

  @:attribute var plugin:IncrementingPlugin;

}
