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

  @test('Special characters can be escaped')
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

  @test('innerHTML')
  public function testDangerousHTML() {
    Pilot.html(<div @dangerouslySetInnerHTML="<p>foo</p>"></div>)
      .render()
      .toString()
      .equals('<div><div><p>foo</p></div></div>');
  }

  @test('Keys preserve order')
  public function testKeys() {
    var root = new Root(Document.root.createElement('div'));
    var tester = (values:Array<{ content:String }>) -> Pilot.html(<ul>
      @for (value in values) <li @key={value}>{value.content}</li>
      <li>Last</li>
    </ul>);
    
    var a = { content: 'a' };
    var b = { content: 'b' };

    root.update(tester([ a, b ]));
    root.toString().equals('<div><ul><li>a</li><li>b</li><li>Last</li></ul></div>');
  
    b.content = 'first';

    root.update(tester([ b, a ]));
    root.toString().equals('<div><ul><li>first</li><li>a</li><li>Last</li></ul></div>');
  
    a.content = 'bin';
    b.content = 'after';
    root.update(tester([
      a,
      { content: 'froob' },
      b
    ]));
    root.toString().equals('<div><ul><li>bin</li><li>froob</li><li>after</li><li>Last</li></ul></div>');
  }

  @test('Components render their children without loosing order')
  public function testOrder() {
    var root = new Root(Document.root.createElement('div'));
    var tester = (items:Array<Array<String>>) -> Pilot.html(<>
      @for (item in items) <OrderTestComponent items={item} />
      <div>Last</div> 
    </>);
    root.update(tester([
      [ 'one-one', 'one-two' ],
      [ 'two-one', 'two-two' ],
    ]));
    root.toString().equals('<div><div>one-one</div><div>one-two</div><div>two-one</div><div>two-two</div><div>Last</div></div>');
    root.update(tester([
      [ 'one-foo', 'one-two', 'one-bar' ],
      [ 'three-one', 'three-two' ],
      [ 'two-one', 'two-two' ],
    ]));
    root.toString().equals('<div><div>one-foo</div><div>one-two</div><div>one-bar</div><div>three-one</div><div>three-two</div><div>two-one</div><div>two-two</div><div>Last</div></div>');
    root.update(tester([
      [ 'one-one', 'one-two' ],
      [ 'two-one', 'two-two' ],
    ]));
    root.toString().equals('<div><div>one-one</div><div>one-two</div><div>two-one</div><div>two-two</div><div>Last</div></div>');
  }

}

class OrderTestComponent extends Component {

  @:attribute var items:Array<String>;

  override function render() return html(<>
    @for (item in items) <NestedOrderTestComponent>{item}</NestedOrderTestComponent>  
  </>);

}

class NestedOrderTestComponent extends Component {

  @:attribute var children:Children;

  override function render() return html(<div>{children}</div>);

}