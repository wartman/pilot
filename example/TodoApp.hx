import pilot.Template.html;
import todo.data.Store;
import todo.ui.App;

class TodoApp {

  static function main() {
    #if js 
      var root = js.Browser.document.getElementById('root');
    #else
      var root = new pilot.Node('div');
      root.setAttribute('id', 'root');
    #end

    var store = new Store(store -> html(<App store={store} />), root);
    store.update();

    #if !js
      Sys.print(root.toString());
    #end
  }

}

// class Test extends Component {
  
//   @:attribute var title:String;
//   @:attribute var count:Int = 1;

//   override function render() {
//     return html(<div class="test">
//       <header>
//         <h1>Stuff!</h1>
//       </header>
//       <p>{title}</p>
//       <if {title == "bar"}>
//         Yay bar
//       <else>
//         Not bar :(
//       </if>
//       <p>Extra {Std.string(count)}</p>
//       <Pure content="ok">Test</Pure>
//       <button onClick={_ -> {
//         trace(count);
//         count++;
//       }}>More!</button>
//     </div>);
//   }

// }

// abstract Pure(PureComponent) to PureComponent {
  
//   public function new(props:{
//     content:String,
//     children:Children
//   }) {
//     this = html(<div class="pure">
//       <p>{props.content}</p>
//       <div>{props.children}</div>
//     </div>);
//   }

// }

// import pilot.Style;
// import todo.ui.App;
// import todo.data.Store;
// import todo.ui.Color;

// class TodoApp {
  
//   public static var color = '#4d4d4d';

//   public static function main() {
//     #if js
//       var store = new Store(
//         store -> new App({ store: store }),
//         js.Browser.document.getElementById('root')
//       );
//       store.update();
//     #else
//       var store = new Store(store -> new App({ store: store }));
//       store.update();
//     #end
//   }

// }
