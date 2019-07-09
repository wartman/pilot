package todo.data;

class Todo {
  
  static var ids:Int = 0;

  public final id:Int = ids++;
  public var content:String;
  public var complete:Bool = false;

  public function new(content) {
    this.content = content;
  }

}
