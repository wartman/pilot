package pilot2.target.dom;

import js.html.Node;
import pilot2.diff.*;

class DomFactory {
  
  static final text = new DomTextNodeType();
  static final tags:Map<String, DomNodeType<Dynamic>> = [];
  static final widgets:Map<String, DomWidgetType<Dynamic>> = [];

  public static function getNodeType(name:String):DomNodeType<Dynamic> {
    if (!tags.exists(name)) {
      tags.set(name, new DomNodeType(name));
    } 
    return tags.get(name);
  }
  
  public static function getWidgetType<Attrs>(type:String, factory:(attrs:Attrs)->Widget<Node>):DomWidgetType<Dynamic> {
    if (!widgets.exists(type)) {
      widgets.set(type, new DomWidgetType(factory));
    } 
    return widgets.get(type);
  }

  inline static public function f(children:Array<VNode<Node>>):VNode<Node> {
    return VFragment(children);
  }

  inline static public function h<Attrs>(name:String, attrs:Attrs, children:Array<VNode<Node>>, ?key:Key):VNode<Node> {
    return VNative(getNodeType(name), attrs, children, key);
  }

  inline static public function w<Attrs>(type:String, factory:(attrs:Attrs)->Widget<Node>, attrs:Attrs, ?key:Key):VNode<Node> {
    return VWidget(getWidgetType(type, factory), attrs, key);
  }

  inline static public function txt(value:String, ?key:Key):VNode<Node> {
    return VNative(text, value, [], key);
  }

}
