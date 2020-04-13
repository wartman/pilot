package pilot;

using Medic;
using pilot.TestHelpers;

class ComponentTest implements TestCase {
  
  public function new() {}

  @test('Component instance can be passed as a value')
  @async
  public function testInstance(done) {
    var context = TestHelpers.createContext();
    var node = context.engine.createNode('div');
    var root = new Root(node, context);
    var comp = new ComponentTester({ text: 'foo', isState: false }, context);
    root.update(Pilot.html(<>{comp}</>));
    root.toString().equals('<div><div><span>Text:foo</span><span>Opt:</span><span>Def:def</span></div></div>');
    comp.isState = true;
    wait(() -> {
      root.toString().equals('<div><div><span>Text:foo</span><span>Opt:</span><span>Def:def</span><span>State:true</span></div></div>');
      done();
    });
  }
  
  @test('Simple guards')
  @async(2000)
  public function testGuards(done) {
    var context = TestHelpers.createContext();
    var node = context.engine.createNode('div');
    var root = new Root(node, context);
    var comp = new GuardedRender({
      value: 'foo'
    }, context);

    root.update(Pilot.html(<>{comp}</>));

    comp.renderCount.equals(1);
    root.toString().equals('<div><div>foo1</div></div>');

    comp.value = 'bar';
    wait(() -> {
      comp.renderCount.equals(2);
      root.toString().equals('<div><div>bar2</div></div>');

      comp.value = 'skip';
      wait(() -> {
        comp.renderCount.equals(2);
        root.toString().equals('<div><div>bar2</div></div>');

        comp.value = 'bar';
        wait(() -> {
          comp.renderCount.equals(2);
          root.toString().equals('<div><div>bar2</div></div>');
          
          comp.blockRender = true;
          comp.value = 'ignored';
          wait(() -> {
            comp.renderCount.equals(2);
            root.toString().equals('<div><div>bar2</div></div>');

            
            comp.blockRender = false;
            wait(() -> {
              comp.renderCount.equals(3);
              root.toString().equals('<div><div>ignored3</div></div>');
              
              comp.value = 'foo';
              wait(() -> {
                comp.renderCount.equals(4);
                root.toString().equals('<div><div>foo4</div></div>');
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
    var context = TestHelpers.createContext();
    var node = context.engine.createNode('div');
    var root = new Root(node, context);
    var comp = new GuardedRender({
      value: 'foo'
    }, context);

    root.update(Pilot.html(<>{comp}</>));
    root.update(Pilot.html(<>{comp}</>));
    
    wait(() -> {
      comp.effectCount.equals(2);
      comp.priorityEffects.equals('first|second|last');
      done();
    });
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

  @test('Components correctly list the number of their child nodes when children update')
  @async
  public function testComponentChildren(done) {
    var context = TestHelpers.createContext();
    var node = context.engine.createNode('div');
    var root = new Root(node, context);
    var parent = new HasChildComponent({}, context);
    root.update(Pilot.html(<>{parent}</>));
    parent.__getNodes().length.equals(1);
    parent.child.setNumChildren(3);
    wait(() -> {
      parent.__getNodes().length.equals(3);
      parent.child.setNumChildren(1);
      wait(() -> {
        parent.__getNodes().length.equals(1);
        done();
      });
    });
  }

  inline function wait(cb:()->Void) {
    cb.later();
  }

}

class ComponentTester extends Component {

  @:attribute var text:String;
  @:attribute( optional ) var opt:String;
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
  public var priorityEffects:String;

  @:attribute(
    state = true, 
    guard = value != 'skip'
  ) public var value:String;
  @:attribute(state) public var blockRender:Bool = false;

  @:guard
  function shouldBlock(attrs) {
    return !(blockRender || attrs.blockRender);
  }

  @:effect( priority = 1 )
  public function testEffect() {
    effectCount++;
  }

  @:effect( priority = 2 )
  public function shouldComeFirst() {
    priorityEffects = 'first';
  }

  @:effect( priority = 3 )
  public function shouldComeNext() {
    priorityEffects += '|second';
  }

  @:effect( priority = 4 )
  public function shouldComeLast() {
    priorityEffects += '|last';
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

class HasChildComponent extends Component {

  public var child:ChildComponent;

  override function render() {
    child = new ChildComponent({ numChildren: 1 }, __context);
    return html(<>
      {child}
    </>);
  }

}

class ChildComponent extends Component {

  @:attribute var numChildren:Int;

  @:update
  public function setNumChildren(num:Int) {
    return { numChildren: num };
  }

  override function render() return html(<>
    @for (i in 0...numChildren) <p>{i}</p>
  </>);

}
