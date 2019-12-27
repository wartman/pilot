package pilot;

import pilot.dom.*;

using medic.Assert;

class ComponentTest {
  
  public function new() {}

  @test('Component instance can be passed as a value')
  public function testInstance() {
    var node = Document.root.createElement('div');
    var root = new Root(node);
    var comp = new ComponentTester({ text: 'foo', isMutable: false }, root.getContext());
    root.update(Pilot.html(<>{comp}</>));
    node.innerHTML.equals('<div><span>Text:foo</span><span>Opt:</span><span>Def:def</span></div>');
    comp.isMutable = true;
    node.innerHTML.equals('<div><span>Text:foo</span><span>Opt:</span><span>Def:def</span><span>Mut:true</span></div>');
  }
  
  @test('Simple guards')
  public function testGuards() {
    var node = Document.root.createElement('div');
    var root = new Root(node);
    var comp = new GuardedRender({
      value: 'foo'
    }, root.getContext());

    root.update(Pilot.html(<>{comp}</>));

    comp.renderCount.equals(1);
    node.innerHTML.equals('<div>foo1</div>');

    comp.value = 'bar';
    comp.renderCount.equals(2);
    node.innerHTML.equals('<div>bar2</div>');

    comp.value = 'skip';
    comp.renderCount.equals(2);
    node.innerHTML.equals('<div>bar2</div>');

    comp.value = 'bar';
    comp.renderCount.equals(2);
    node.innerHTML.equals('<div>bar2</div>');
    
    comp.blockRender = true;
    comp.value = 'ignored';
    comp.renderCount.equals(2);
    node.innerHTML.equals('<div>bar2</div>');

    comp.blockRender = false;
    comp.renderCount.equals(3);
    node.innerHTML.equals('<div>ignored3</div>');
    comp.value = 'foo';
    comp.renderCount.equals(4);
    node.innerHTML.equals('<div>foo4</div>');
  }

}

class ComponentTester extends Component {

  @:attribute var text:String;
  @:attribute @:optional var opt:String;
  @:attribute var def:String = 'def';
  @:attribute(mutable) public var isMutable:Bool;

  override function render() return html(<>
    <div>
      <span>Text:{text}</span>
      <span>Opt:{opt}</span>
      <span>Def:{def}</span>
      @if (isMutable) <span>Mut:true</span>
    </div>
  </>);

}

class GuardedRender extends Component {

  public var renderCount:Int = 0;

  @:attribute(
    mutable = true, 
    guard = (incoming, current) -> incoming != 'skip'
  ) public var value:String;
  @:attribute(mutable) public var blockRender:Bool = false;

  @:guard
  function shouldBlock(attrs) {
    return !(blockRender || attrs.blockRender);
  }

  override function render() {
    renderCount++;
    return html(
      <div>{value + renderCount}</div>
    );
  }

}
