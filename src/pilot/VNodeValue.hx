package pilot;

abstract VNodeValue(VNode) from VNode to VNode {

  @:from inline public static function ofString(content:String):VNodeValue {
    return VNode.VNative(TextType, content, []);
  }

  @:from inline public static function ofInt(content:Int):VNodeValue {
    return VNode.VNative(TextType, Std.string(content), []);
  }

  @:from inline public static function ofFloat(content:Float):VNodeValue {
    return VNode.VNative(TextType, Std.string(content), []);
  }

  @:from inline public static function ofChildren(children:Children):VNodeValue {
    return VNode.VFragment(children);
  }

  @:from inline public static function ofComponentInstance(component:Component):VNodeValue {
    return VNode.VComponent({
      _pilot_create: (_, _) -> component
    }, @:privateAccess component._pilot_attrs);
  }

}
