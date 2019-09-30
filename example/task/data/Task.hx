package task.data;

enum TaskStatus {
  Completed;
  Pending;
  Abandoned;
}

typedef TaskObject = {
  var id:Int;
  var content:String;
  var status:TaskStatus;
}

@:forward
abstract Task(TaskObject) {
  
  static var ids:Int = 0;

  public static function create(content:String, status:TaskStatus = Pending) {
    return new Task({
      id: ids++,
      content: content,
      status: status
    });
  }

  inline public function new(task:TaskObject) {
    this = task;
  }

}
