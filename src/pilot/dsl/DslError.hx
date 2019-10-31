package pilot.dsl;

class DslError {
  
  public final message:String;
  public final pos:{ min:Int, max:Int };

  public function new(message:String, pos:{ min:Int, max:Int }) {
    this.message = message;
    this.pos = pos;
  }

  public function toString() {
    var pos:Int = pos.min < 0 
      ? 0
      : pos.max > pos.min
        ? pos.max - pos.min
        : pos.min; 
    return '${message} : ${pos}';
  }

}
