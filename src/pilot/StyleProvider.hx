package pilot;

class StyleProvider implements Widget {

  // static macro function injectStyles(ethis) {
  //   var content = pilot.macro.StyleBuilder.content;
  //   var out:Array<haxe.macro.Expr> = [ for (_ => data in content)
  //     macro instance.add($v{data})
  //   ];
  //   return macro {
  //     var instance = ${ethis};
  //     $b{out};
  //     instance.inject();
  //   }
  // }

  static var initialized:Bool = false;
  static var styleEl:js.html.StyleElement;
  static var globalStyles:Array<String>;

  public static function addGlobalStyle(style:String) {
    if (globalStyles == null) {
      globalStyles = [];
    }
    globalStyles.push(style);
  }

  final styles = [];
  final child:VNode;

  public function new(props:{
    child:VNode
  }) {
    child = props.child;
  }

  public function add(style:String) {
    styles.push(style);
  }

  public function inject() {
    if (styleEl == null) {
      var head = js.Browser.document.head;
      styleEl = js.Browser.document.createStyleElement();
      styleEl.setAttribute('id', 'pilot-styles');
      styleEl.setAttribute('rel', 'stylesheet');
      head.appendChild(styleEl);
    }
    styleEl.innerHTML = styles.concat(globalStyles).join('\n');
  }

  public function render():VNode {
    if (!initialized) {
      initialized = true;
      inject();
    }
    return child;
  }

}