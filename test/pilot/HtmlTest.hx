package pilot;

import pilot.Html;

using Medic;
using pilot.TestHelpers;

class HtmlTest implements TestCase {
  
  public function new() {}

  @test('Can build HTML without markup')
  public function simple() {
    Html.h('div', { 'class': 'foo' }, [ Html.text('bar') ])
      .render()
      .toString()
      .equals('<div><div class="foo">bar</div></div>');
  }

  @test('Components can be used without markup too')
  public function componentNode() {
    SimpleComponent.node({ content: 'test' })
      .render()
      .toString()
      .equals('<div><p>test</p></div>');
  }

}

class SimpleComponent extends Component {

  @:attribute var content:String;

  override function render() return Html.h('p', {}, [ 
    Html.text(content) 
  ]);

}
