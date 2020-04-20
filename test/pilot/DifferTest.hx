package pilot;

import haxe.ds.Option;

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
    init.replace(Html.create(<div @dangerouslySetInnerHtml="before foo after" />));
    init.toString().equals('<div><div>before foo after</div></div>');

    var root = new Root(target, ctx);
    root.hydrate(template('foo'));
    root.toString().equals('<div><div>before foo after</div></div>');
  }

}
