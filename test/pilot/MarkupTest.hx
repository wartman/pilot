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

  @test('For loop with else works')
  public function testLoopElse() {
    var tester = (items:Array<String>) -> 
      Pilot.html(<>
        <for {item in items}>
          {item}
        <else>
          <span>None</span>
        </for>
      </>)
      .render()
      .outerHTML;
    tester([ 'a', 'b', 'c' ]).equals('<div>abc</div>');
    tester(null).equals('<div><span>None</span></div>');
  }

  @test('Switch works')
  public function testSwitch() {
    var tester = (value:String) ->
      Pilot.html(<>
        <switch {value}>
          <case {'foo'}>Foo</case>
          <case {'bar'}>Bar</case>
          <case {thing}>Other {thing}</case>
        </switch>
      </>)
      .render()
      .outerHTML;
    tester('foo').equals('<div>Foo</div>');
    tester('bar').equals('<div>Bar</div>');
    tester('bax').equals('<div>Other bax</div>');
  }

  @test('If works')
  public function testIf() {
    var tester = (ok:Bool) -> 
      Pilot.html(<if {ok}>Ok!<else>Not ok!</if>)
      .render()
      .outerHTML;
    tester(false).equals('<div>Not ok!</div>');
    tester(true).equals('<div>Ok!</div>');
  }

}
