package pilot.message;

import pilot.dom.*;
import pilot.*;

using Medic;

class MessageTest implements TestCase {

  public function new() {}

  @test('Messages are initialized correctly')
  public function messageInit() {
    var node = Document.root.createElement('div');
    var root = new Root(node);
    var store:Store<TestAction, TestData> = new Store({ foo: 'foo' });
    root.update(Pilot.html(<StoreProvider store={store}>
      <TestMessageComponent />
    </StoreProvider>));
    root.toString().equals('<div>foo</div>');
  }

}

enum TestAction {
  None;
  SetFoo(foo:String);
}

typedef TestData = {
  foo:String
}

@:update(switch message {
  case None: null;
  case SetFoo(foo): { foo: foo }; 
})
class TestMessage extends Message<TestAction, TestData> {

  @:state( map = data.foo ) var message:String;

  @:send
  public function setFoo(foo:String):TestAction {
    return SetFoo(foo);
  }

}

class TestMessageComponent extends Component {

  @:attribute var test:TestMessage = new TestMessage();

  override function render() return html(<>{test.message}</>);

}
