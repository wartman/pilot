package pilot;

using Medic;

class SignalTest implements TestCase {
  
  public function new() {}

  @test('Dispatches listeners')
  public function simpleDispatch() {
    var s = new Signal<Int>();
    var i:Int = 1;
    s.add(n -> i += n);
    s.dispatch(2);
    i.equals(3);
    s.dispatch(1);
    i.equals(4);
  }

  @test('addOnce will only dispatch a signal once')
  public function addOnceWorks() {
    var s = new Signal<Int>();
    var i:Int = 1;
    s.addOnce(n -> i += n);
    s.dispatch(2);
    i.equals(3);
    s.dispatch(1);
    s.dispatch(9000);
    i.equals(3);
  }

  @test('Subscriptions can be canceled')
  public function testSubscriptions() {
    var s = new Signal<Int>();
    var i:Int = 1;
    var sub = s.add(n -> i += n);
    s.dispatch(2);
    i.equals(3);
    sub.cancel();
    s.dispatch(1);
    s.dispatch(9000);
    i.equals(3);
  }

}
