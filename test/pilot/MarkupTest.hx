package pilot;

using medic.Assert;
using pilot.MarkupTest;

class MarkupTest {

  public function new() {}

  public static function render(vn:VNode) {
    var node = new Node('div');
    var root = new Root(node);
    root.update(vn);
    return node;
  }

  @test('For loop works')
  public function testLoop() {
    var items = [ 'a', 'b', 'c' ];
    Pilot
      .html(<>
        <for {item in items}>
          {item}
        </for>
      </>)
      .render()
      .outerHTML
      .equals('<div>abc</div>');
  }

  @test('If works')
  public function testIf() {
    var tester = (ok:Bool) -> Pilot
      .html(<if {ok}>Ok!<else>Not ok!</if>)
      .render()
      .outerHTML;
    tester(false).equals('<div>Not ok!</div>');
    tester(true).equals('<div>Ok!</div>');
  }

}
