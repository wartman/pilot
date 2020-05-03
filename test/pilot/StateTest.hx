package pilot;

using Medic;

class StateTest implements TestCase {

  public function new() {}

  @test('States can be constructed')
  public function testStateCreation() {
    var ctx = TestHelpers.createContext();
    var state = new SimpleState({ foo: 'foo', children: [] }, ctx);
    state.foo.equals('foo');
  }

  @test('States can be consumed by child components')
  public function testStateConsume() {
    var context = TestHelpers.createContext();
    var node = context.engine.createNode('div');
    var root = new Root(node, context);
    root.update(Pilot.html(
      <SimpleState foo="foo">
        <ConsumeSimpleState />
      </SimpleState>
    ));
    root.toString().equals('<div><p>foo</p></div>');
  }

  @test('States update all child components when changed')
  @async
  public function testStateUpdate(done) {
    var context = TestHelpers.createContext();
    var node = context.engine.createNode('div');
    var state = new SimpleState({ foo: 'foo', children: [
      ConsumeSimpleState.node({})
    ] }, context);
    var root = new Root(node, context);
    root.update(Pilot.html(<>{state}</>));
    root.toString().equals('<div><p>foo</p></div>');
    state.setFoo('bar');
    TestHelpers.later(() -> {
      root.toString().equals('<div><p>bar</p></div>');
      done();
    });
  }

}

class SimpleState extends State {

  @:attribute var foo:String;

  @:transition
  public function setFoo(foo:String) {
    return { foo: foo };
  }

}

class ConsumeSimpleState extends Component {

  @:attribute(consume) var state:SimpleState;

  override function render() return html(<p>{state.foo}</p>);
  
}
