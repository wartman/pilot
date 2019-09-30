import task.data.Store;
import pilot2.Context;
import pilot2.VNode;
import pilot2.Widget;
import task.ui.App;

class Test {

  static function main() {
    var ctx = new Context();
    #if js
      var root = js.Browser.document.getElementById('root');
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
        ctx.mount(root, new VNode({
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
            new App({}),
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
    #else
      ctx.render(new TestWidget({ 
        title: 'foo'
      }));
    #end
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
    trace('Was patched!');
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
            #if js
              onClick: e -> {
                index++;
              }
            #end
          },
          children: [ 'Make Bar' ]
        })
      ]
    });
  }

}
