package pilot;

import pilot.html.*;

using medic.Assert;

class ComponentTest {
  
  public function new() {}

  @test('Component instance can be passed as a value')
  public function testInstance() {
    var node = Document.root.createElement('div');
    var root = new Root(node);
    var comp = new ComponentTester({ text: 'foo', isMutable: false }, null);
    root.update(Pilot.html(<>{comp}</>));
    node.innerHTML.equals('<div><span>Text:foo</span><span>Opt:</span><span>Def:def</span></div>');
    comp.isMutable = true;
    node.innerHTML.equals('<div><span>Text:foo</span><span>Opt:</span><span>Def:def</span><span>Mut:true</span></div>');
  }
  
  // todo: more tests

}

class ComponentTester extends Component {

  @:attribute var text:String;
  @:attribute @:optional var opt:String;
  @:attribute var def:String = 'def';
  @:attribute(mutable = true) public var isMutable:Bool;

  override function render() return html(<>
    <div>
      <span>Text:{text}</span>
      <span>Opt:{opt}</span>
      <span>Def:{def}</span>
      <if {isMutable}>
        <span>Mut:true</span>
      </if>
    </div>
  </>);

}