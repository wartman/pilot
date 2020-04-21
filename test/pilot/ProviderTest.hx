package pilot;

using Medic;
using pilot.TestHelpers;

class ProviderTest implements TestCase {

  public function new() {}

  @test('Gets injected') 
  public function testSimple() {
    Pilot.html(<Provider id="foo" value="foo">
      <TestProviderConsumer />
    </Provider>)
      .render()
      .toString()
      .equals('<div><p>foo</p></div>');
  }

  
  @test('Updates take effect') 
  public function testUpdate() {
    var ctx = TestHelpers.createContext();
    var root = new Root(ctx.engine.createNode('div'), ctx);
    var template = foo -> Pilot.html(<Provider id="foo" value={foo}>
      <TestProviderConsumer />
    </Provider>);

    root.replace(template('foo'));
    root.toString().equals('<div><p>foo</p></div>');
    root.update(template('bar'));
    root.toString().equals('<div><p>bar</p></div>');
  }
  
  
}

class TestProviderConsumer extends Component {

  @:attribute(inject = 'foo') var foo:String;

  override function render() return html(<p>{foo}</p>);

}
