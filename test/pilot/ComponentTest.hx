package pilot;

import pilot.dom.*;

using Medic;
using pilot.TestHelpers;

class ComponentTest implements TestCase {
  
  public function new() {}

  @test('Component instance can be passed as a value')
  @async
  public function testInstance(done) {
    var node = Document.root.createElement('div');
    var root = new Root(node);
    var comp = new ComponentTester({ text: 'foo', isState: false }, root.getContext());
    root.update(Pilot.html(<>{comp}</>));
    node.innerHTML.equals('<div><span>Text:foo</span><span>Opt:</span><span>Def:def</span></div>');
    comp.isState = true;

    // Patch will happen async.
    wait(() -> {
      node.innerHTML.equals('<div><span>Text:foo</span><span>Opt:</span><span>Def:def</span><span>State:true</span></div>');
      done();
    });
  }
  
  @test('Simple guards')
  @async(2000)
  public function testGuards(done) {
    var node = Document.root.createElement('div');
    var root = new Root(node);
    var comp = new GuardedRender({
      value: 'foo'
    }, root.getContext());

    root.update(Pilot.html(<>{comp}</>));

    comp.renderCount.equals(1);
    node.innerHTML.equals('<div>foo1</div>');

    comp.value = 'bar';
    wait(() -> {
      comp.renderCount.equals(2);
      node.innerHTML.equals('<div>bar2</div>');

      comp.value = 'skip';
      wait(() -> {
        comp.renderCount.equals(2);
        node.innerHTML.equals('<div>bar2</div>');

        comp.value = 'bar';
        wait(() -> {
          comp.renderCount.equals(2);
          node.innerHTML.equals('<div>bar2</div>');
          
          comp.blockRender = true;
          comp.value = 'ignored';
          wait(() -> {
            comp.renderCount.equals(2);
            node.innerHTML.equals('<div>bar2</div>');

            
            comp.blockRender = false;
            wait(() -> {
              comp.renderCount.equals(3);
              node.innerHTML.equals('<div>ignored3</div>');
              
              comp.value = 'foo';
              wait(() -> {
                comp.renderCount.equals(4);
                node.innerHTML.equals('<div>foo4</div>');
                done();
              });
            });
          });
        });
      });
    });
  }

  @test('simple effects')
  @async
  public function testEffect(done) {
    var node = Document.root.createElement('div');
    var root = new Root(node);
    var comp = new GuardedRender({
      value: 'foo'
    }, root.getContext());

    root.update(Pilot.html(<>{comp}</>));
    root.update(Pilot.html(<>{comp}</>));
    
    wait(() -> {
      comp.effectCount.equals(2);
      done();
    });
  }

  inline function wait(cb:()->Void) {
    cb.later();
  }

  @test('Component type params')
  public function testParams() {
    Pilot.html(<>
      <ComponentWithTypeParam
        build={data -> <p>{data}</p>}
        data="foo"
      />
    </>)
      .render()
      .toString()
      .equals('<div><p>foo</p></div>');
  }

}

class ComponentTester extends Component {

  @:attribute var text:String;
  @:attribute @:optional var opt:String;
  @:attribute var def:String = 'def';
  @:attribute(state) public var isState:Bool;

  override function render() return html(<>
    <div>
      <span>Text:{text}</span>
      <span>Opt:{opt}</span>
      <span>Def:{def}</span>
      @if (isState) <span>State:true</span>
    </div>
  </>);

}

class GuardedRender extends Component {

  public var renderCount:Int = 0;
  public var effectCount:Int = 0;

  @:attribute(
    state = true, 
    guard = (incoming, current) -> incoming != 'skip'
  ) public var value:String;
  @:attribute(state) public var blockRender:Bool = false;

  @:guard
  function shouldBlock(attrs) {
    return !(blockRender || attrs.blockRender);
  }

  @:effect
  public function testEffect() {
    effectCount++;
  }

  override function render() {
    renderCount++;
    return html(
      <div>{value + renderCount}</div>
    );
  }

}

class ComponentWithTypeParam<T> extends Component {

  @:attribute var data:T;
  @:attribute var build:(data:T)->VNode;

  override function render() return html(<>{build(data)}</>);

}
