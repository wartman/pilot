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
        @for (item in items) { item; }
      </>)
      .render()
      .toString()
      .equals('<div>abc</div>');
  }

  @test('For loop with else works')
  public function testLoopElse() {
    var tester = (items:Array<String>) -> 
      Pilot.html(<>
        @if (items == null) {
          <span>None</span>
        } else {
          [ for (item in items) item ];
        }
      </>)
      .render()
      .toString();
    tester([ 'a', 'b', 'c' ]).equals('<div>abc</div>');
    tester(null).equals('<div><span>None</span></div>');
  }
  
  @test('Switch works')
  public function testReenterSwitch() {
    var tester = (value:String) ->
      Pilot.html(<>
        @switch value {
          case 'foo': <span>Foo</span>;
          case 'bar': <span>Bar</span>;
          case thing: <span>Other {thing}</span>;
        }
      </>)
      .render()
      .toString();
    tester('foo').equals('<div><span>Foo</span></div>');
    tester('bar').equals('<div><span>Bar</span></div>');
    tester('bax').equals('<div><span>Other bax</span></div>');
  }

}
