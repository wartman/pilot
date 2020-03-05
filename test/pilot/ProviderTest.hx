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
  
}

class TestProviderConsumer extends Component {

  @:attribute(inject = 'foo') var foo:String;

  override function render() return html(<p>{foo}</p>);

}
