package pilot;

class StyleManager {

  static var ids:Int = 0;
  static var instance:StyleManager;

  public static function getInstance() {
    if (instance == null) {
      instance = new StyleManager();
    }
    return instance;
  }

  final id:String = 'pilot-styles-' + ids++;
  var rules:Array<String> = [];
  var injecting:Bool;

  public function new() {}

  public function add(rule:String):String {
    rules.push(rule);
    inject();
    return rule;
  }
  
  public function inject() {
    if (injecting) { 
      return;
    }
    injecting = true;

    // todo: allow for browsers that might not have requestAnimationFrame.
    js.Browser.window.requestAnimationFrame(_ -> {
      var styles = js.Browser.document.getElementById(id);
      var toInject = rules.copy();
      rules = [];
      
      if (styles == null) {
        var head = js.Browser.document.head;
        styles = js.Browser.document.createStyleElement();
        styles.setAttribute('id', id);
        styles.setAttribute('rel', 'stylesheet');
        head.appendChild(styles);
      }
    
      styles.innerHTML = [styles.innerHTML].concat(toInject).join('\n');
      injecting = false;
    });
  }

}
