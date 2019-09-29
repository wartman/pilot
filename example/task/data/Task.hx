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

abstract Task(TaskObject) {
  
  inline public function new(task:TaskObject) {
    this = task;
  }

}
