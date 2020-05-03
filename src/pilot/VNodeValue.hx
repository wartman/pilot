package pilot;

import pilot.VNode;

abstract VNodeValue(VNode) from VNode to VNode {

  @:from inline public static function ofString(content:String):VNodeValue {
    return VNative(TextType, { content: content }, []);
  }

  @:from inline public static function ofStringArray(content:Array<String>):VNodeValue {
    return VFragment([ for (c in content) ofString(c) ]);
  }

  @:from inline public static function ofInt(content:Int):VNodeValue {
    return VNative(TextType, { content: Std.string(content) }, []);
  }

  @:from inline public static function ofFloat(content:Float):VNodeValue {
    return VNative(TextType, { content: Std.string(content) }, []);
  }

  @:from inline public static function ofChildren(children:Children):VNodeValue {
    return VFragment(children);
  }

  @:from inline public static function ofComponentInstance(component:Component):VNodeValue {
    return VComponent({
      __create: (_, _) -> cast component
    }, untyped component.__attrs); // HMMM
  }

  @:from inline public static function ofStateInstance(state:State):VNodeValue {
    return VComponent({
      __create: (_, _) -> cast state
    }, untyped state.__attrs); // HMMM
  }

}
