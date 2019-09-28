import pilot2.VNode;
import pilot2.Differ;
import pilot2.Widget;

class Test {

  static function main() {
    var root = js.Browser.document.getElementById('root');
    var differ = new Differ();
    // differ.hooks.add(HookCreate(vn -> {
    //   trace('Create:');
    //   trace(vn);
    // }));
    // differ.hooks.add(HookUpdate((_, vn) -> {
    //   trace('Update:');
    //   trace(vn);
    // }));
    // differ.hooks.add(HookRemove((vn) -> {
    //   trace('Remove:');
    //   trace(vn);
    // }));
    function render(name:String) {
      differ.patch(root, new VNode({
        name: 'div',
        props: {
          // if this ID isn't here the patch won't work
          // which is worrying
          id: 'root'
        },
        children: [
          new TestWidget({ 
            title: name
          }),
          new VNode({
            name: 'button',
            props: {
              onClick: _ -> render('Reset')
            },
            children: [ 'Reset' ]
          })
        ]
      }));
    }
    render('foo');
  }

}

class TestWidget extends Widget {
  
  @:prop var title:String;
  @:prop.state var index:Int = 0;

  @:hook.prePatch
  function testBefore(oldVn, newVn) {
    trace('Will be patched!');
  }

  @:hook.postPatch
  function testAfter(oldVn, newVn) {
    trace('Was be patched!');
  }

  override function build():VNode {
    return new VNode({
      name: 'div',
      props: {
        className: 'test'
      },
      children: [
        [ title, ' ', index ],
        [ ' example ', 'of arrays' ],
        new VNode({
          name: 'button',
          props: {
            onClick: e -> {
              index++;
            }
          },
          children: [ 'Make Bar' ]
        })
      ]
    });
  }

}
