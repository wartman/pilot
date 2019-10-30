import js.Browser;
import pilot2.Component;
import pilot2.PureComponent;
import pilot2.Children;
import pilot2.Renderer;
import pilot2.Template.html;

class TodoApp {

  static function main() {
    Renderer.mount(
      Browser.document.body,
      html(<div>
        <Test title="foo" />
        <Test title="bar" />
      </div>)
    );
  }

}

class Test extends Component {
  
  @:attribute var title:String;
  @:attribute var count:Int = 1;

  override function render() {
    return html(<div class="test">
      <header>
        <h1>Stuff!</h1>
      </header>
      <p>{title}</p>
      <if {title == "bar"}>
        Yay bar
      <else>
        Not bar :(
      </if>
      <p>Extra {Std.string(count)}</p>
      <Pure content="ok">Test</Pure>
      <button onClick={_ -> {
        trace(count);
        count++;
      }}>More!</button>
    </div>);
  }

}

abstract Pure(PureComponent) to PureComponent {
  
  public function new(props:{
    content:String,
    children:Children
  }) {
    this = html(<div class="pure">
      <p>{props.content}</p>
      <div>{props.children}</div>
    </div>);
  }

}

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
