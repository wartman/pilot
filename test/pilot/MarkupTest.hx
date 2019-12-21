package pilot;

import pilot.dom.*;

using medic.Assert;
using pilot.MarkupTest;

class MarkupTest {

  public function new() {}

  public static function render(vn:VNode) {
    var root = new Root(Document.root.createElement('div'));
    root.update(vn);
    return root;
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
      .toString()
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
      .toString();
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
      .toString();
    tester('foo').equals('<div>Foo</div>');
    tester('bar').equals('<div>Bar</div>');
    tester('bax').equals('<div>Other bax</div>');
  }

  @test('If works')
  public function testIf() {
    var tester = (ok:Bool) -> 
      Pilot.html(<if {ok}>Ok!<else>Not ok!</if>)
      .render()
      .toString();
    tester(false).equals('<div>Not ok!</div>');
    tester(true).equals('<div>Ok!</div>');
  }

}
