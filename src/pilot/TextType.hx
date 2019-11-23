package pilot;

class TextType {
  
  public static function _pilot_create(attrs:String, context:Context):Wire<String> {
    return new TextWire(attrs);
  }

}
