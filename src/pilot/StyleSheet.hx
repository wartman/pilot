package pilot;

class StyleSheet {

  static var instance:StyleSheet;

  public static function getInstance() {
    if (instance == null) {
      instance = new StyleSheet();
    }
    return instance;
  }

  final rules:Array<String> = [];
  var injected:Bool;

  public function new() {}

  public function add(rule:String):String {
    rules.push(rule);
    return rule;
  }
  
  public function inject() {
    if (injected) { 
      return;
    }
    injected = true;
    var head = js.Browser.document.head;
    var styles = js.Browser.document.createStyleElement();
    styles.setAttribute('id', 'pilot-styles');
    styles.setAttribute('rel', 'stylesheet');
    head.appendChild(styles);
    styles.innerHTML = rules.join('\n');
  }

}