package pilot;

using Medic;

class DifferTest implements TestCase {

  public function new() {}

  @test('Replace works')
  public function testReplace() {
    var ctx = TestHelpers.createContext();
    var template = (foo:String) -> Html.create(
      <div class="bar">{foo}</div>
    );
    var target = ctx.engine.createNode('div');
    var child = ctx.engine.createNode('p');
    child.appendChild(ctx.engine.createTextNode('Stuff'));
    target.appendChild(child);

    var root = new Root(target, ctx);
    root.toString().equals('<div><p>Stuff</p></div>');
    root.replace(template('foo'));
    root.toString().equals('<div><div class="bar">foo</div></div>');
  }

  @test('Hydration works')
  public function testHydration() {
    var ctx = TestHelpers.createContext();
    var template = (foo:String) -> Html.create(
      <div class="bar">{foo}</div>
    );
    var target = ctx.engine.createNode('div');
    
    var init = new Root(target, ctx);
    init.replace(template('foo'));
    init.toString().equals('<div><div class="bar">foo</div></div>');

    var root = new Root(target, ctx);
    root.hydrate(template('foo'));
    root.toString().equals('<div><div class="bar">foo</div></div>');
  }

  @test('Hydration works with text')
  public function testHydrateText() {
    var ctx = TestHelpers.createContext();
    var template = (foo:String) -> Html.h('div', {}, [
      Html.text('before '),
      Html.text(foo),
      Html.text(' after')
    ]);
    var target = ctx.engine.createNode('div');
    
    var init = new Root(target, ctx);
    init.replace(Html.create(<div>before foo after</div>));
    init.toString().equals('<div><div>before foo after</div></div>');

    var root = new Root(target, ctx);
    root.hydrate(template('foo'));
    root.toString().equals('<div><div>before foo after</div></div>');
  }

  @test('Hydration works with Components')
  public function testHydratedComponent() {
    var ctx = TestHelpers.createContext();
    var engine = ctx.engine;
    var target = engine.createNode('div');

    var p = engine.createNode('p');
    p.appendChild(engine.createTextNode('foo'));
    target.appendChild(p);

    engine.nodeToString(target).equals('<div><p>foo</p></div>');
    
    var root = new Root(target, ctx);
    root.hydrate(TestConsumer.node({ test: 'foo' }));
    root.toString().equals('<div><p>foo</p></div>');

    root.update(TestConsumer.node({ test: 'changed' }));
    root.toString().equals('<div><p>changed</p></div>');
  }

  @test('Hydration works with nested Components')
  public function testHydratedNestedComponent() {
    var ctx = TestHelpers.createContext();
    var engine = ctx.engine;
    var target = engine.createNode('div');
    var tpl = (foo) -> HasChildrenComponent.node({
      children: [
        HasChildrenComponent.node({
          children: [
            TestConsumer.node({ test: foo }),
            Html.text('bar')
          ]
        })
      ]
    });

    var p = engine.createNode('p');
    p.appendChild(engine.createTextNode('foo'));
    target.appendChild(p);
    target.appendChild(engine.createTextNode('bar'));

    engine.nodeToString(target).equals('<div><p>foo</p>bar</div>');
    
    var root = new Root(target, ctx);
    
    root.hydrate(tpl('foo'));
    root.toString().equals('<div><p>foo</p>bar</div>');

    root.update(tpl('changed'));
    root.toString().equals('<div><p>changed</p>bar</div>');
  }

  @test('Hydration works with placeholders')
  public function testPlaceholders() {
    var ctx = TestHelpers.createContext();
    var engine = ctx.engine;
    var target = engine.createNode('div');

    var p = engine.createNode('p');
    p.appendChild(engine.createTextNode('2'));
    target.appendChild(p);

    engine.nodeToString(target).equals('<div><p>2</p></div>');

    var root = new Root(target, ctx);
    root.hydrate(Pilot.html(<>
      <MightBePlaceholderComponent show={false} value={1} />
      <MightBePlaceholderComponent show={true} value={2} />
      <MightBePlaceholderComponent show={false} value={3} />
      <MightBePlaceholderComponent show={false} value={4} />
    </>));

    root.toString().equals('<div><p>2</p></div>');

    root.update(Pilot.html(<>
      <MightBePlaceholderComponent show={false} value={1} />
      <MightBePlaceholderComponent show={false} value={2} />
      <MightBePlaceholderComponent show={false} value={3} />
      <MightBePlaceholderComponent show={true} value={4} />
    </>));
    root.toString().equals('<div><p>4</p></div>');
  }

  @test('Hydration works with Providers')
  public function testHydratedProvider() {
    var ctx = TestHelpers.createContext();
    var engine = ctx.engine;
    var target = engine.createNode('div');
    var template = (foo:String) -> Provider.node({
      id: 'test',
      value: foo,
      children: [ TestConsumer.node({}) ]
    });

    var p = engine.createNode('p');
    p.appendChild(engine.createTextNode('foo'));
    target.appendChild(p);

    engine.nodeToString(target).equals('<div><p>foo</p></div>');
    
    var root = new Root(target, ctx);
    root.hydrate(template('foo'));
    root.toString().equals('<div><p>foo</p></div>');

    root.update(template('changed'));
    root.toString().equals('<div><p>changed</p></div>');
  }

}

class TestConsumer extends Component {

  @:attribute( inject = 'test' ) var test:String;

  override function render() return html(<p>{test}</p>);

}

class HasChildrenComponent extends Component {

  @:attribute var children:Children;

  override function render() return html(<>{children}</>);

}

class MightBePlaceholderComponent extends Component {

  @:attribute var show:Bool;
  @:attribute var value:Int;

  override function render() {
    if (show) return html(<p>{value}</p>);
    return null;
  }

}
