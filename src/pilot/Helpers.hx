package pilot;

using Reflect;

class Helpers {

  #if js

    static final hasRaf:Bool = js.Syntax.code('window.hasOwnProperty("requestAnimationFrame")');

    public static function delay(fn:()->Void) {
      if (hasRaf) {
        js.Browser.window.requestAnimationFrame(_ -> fn());
      } else {
        js.Browser.window.setTimeout(fn, 100);
      }
    }

  #else

    public static function delay(fn:()->Void) {
      fn();
    }

  #end

  
  public static function applyStyle(vnode:VNode) {
    if (vnode.style != null) {
      vnode.props.setField('className', switch vnode.props.field('className') {
        case null: vnode.style;
        case v: vnode.style.add(new Style(v));
      });
      vnode.style = null;
    }
  }

}
