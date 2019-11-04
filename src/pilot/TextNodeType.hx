package pilot;

import pilot.core.Wire;

class TextNodeType {
  
  public static function _pilot_create(attrs:String):Wire<String, RealNode> {
    return new TextNode(attrs);
  }

}
