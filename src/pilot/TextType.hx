package pilot;

class TextType {
  
  public static function __create(attrs:String, context:Context):Wire<String> {
    return new TextWire(attrs);
  }

}
