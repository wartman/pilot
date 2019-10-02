import pilot2.VNode;
import task.ui.App;
import task.data.Store;

class Test {

  static function main() {
    var store = new Store([], store -> new VNode({
      name: 'div',
      props: { id: 'root' },
      children: [ new App({ store: store }) ]
    }));
    #if js
      store.mount(js.Browser.document.getElementById('root'));
    #else
      store.render();
    #end
  }

}

// class TestWidget extends Widget {
  
//   @:prop var title:String;
//   @:prop.state var index:Int = 0;

//   @:hook.prePatch
//   function testBefore(oldVn, newVn) {
//     trace('Will be patched!');
//   }

//   @:hook.postPatch
//   function testAfter(oldVn, newVn) {
//     trace('Was patched!');
//   }

//   override function build():VNode {
//     return new VNode({
//       name: 'div',
//       props: {
//         className: 'test'
//       },
//       children: [
//         [ title, ' ', index ],
//         [ ' example ', 'of arrays' ],
//         new VNode({
//           name: 'button',
//           props: {
//             #if js
//               onClick: e -> {
//                 index++;
//               }
//             #end
//           },
//           children: [ 'Make Bar' ]
//         })
//       ]
//     });
//   }

// }
