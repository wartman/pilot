package pilot;

import pilot.dom.*;

using pilot.MarkupTest;
using Medic;

class MarkupTest implements TestCase {

  public function new() {}

  public static function render(vn:VNode) {
    var root = new Root(Document.root.createElement('div'));
    root.update(vn);
    return root;
  }

  @test('@if with no else works')
  public function testIf() {
    var tester = (ok:Bool) -> 
      Pilot.html(<>@if (ok) { 'Ok!'; }</>)
      .render()
      .toString();
    tester(false).equals('<div></div>');
    tester(true).equals('<div>Ok!</div>');
  }

  @test('@if with else works')
  public function testIfElse() {
    var tester = (ok:Bool) -> 
      Pilot.html(<>@if (ok) { 'Ok!'; } else { 'Not ok.'; }</>)
        .render()
        .toString();
    tester(false).equals('<div>Not ok.</div>');
    tester(true).equals('<div>Ok!</div>');
  }

  @test('@if works with bare nodes')
  public function testIfNode() {
    var tester = (ok:Bool) -> 
      Pilot.html(<>@if (ok) <p>Ok!</p> else <p>Not ok.</p></>)
        .render()
        .toString();
    tester(false).equals('<div><p>Not ok.</p></div>');
    tester(true).equals('<div><p>Ok!</p></div>');
  }

  @test('`@` can be escaped')
  public function testEscapeAt() {
    var out = Pilot.html(<span>\@\$\<</span>)
      .render()
      .toString();
    out.equals('<div><span>@$&lt;</span></div>');
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

  @test('For loop works with bare nodes')
  public function testLoopNode() {
    var items = [ 'a', 'b', 'c' ];
    Pilot
      .html(<ul>
        @for (item in items) <li>{item}</li>
      </ul>)
      .render()
      .toString()
      .equals('<div><ul><li>a</li><li>b</li><li>c</li></ul></div>');
  }
  
  @test('Switch works')
  public function testReenterSwitch() {
    var tester = (value:String) ->
      Pilot.html(<>
        @switch value {
          case 'foo': <span>Foo</span>
          case 'bar': <span>Bar</span>
          case thing: <span>Other {thing}</span>
        }
      </>)
      .render()
      .toString();
    tester('foo').equals('<div><span>Foo</span></div>');
    tester('bar').equals('<div><span>Bar</span></div>');
    tester('bax').equals('<div><span>Other bax</span></div>');
  }

}
