package task.data;

import pilot2.VNode;
import pilot2.Context;
import task.data.Task;

enum TaskVisibility {
  All;
  Filtered(status:TaskStatus);
}

class Store {

  final build:(store:Store)->VNode;
  final context = new Context();
  var tasks:Array<Task>;
  var filter:TaskVisibility = All;

  public function new(tasks, build) {
    this.tasks = tasks;
    this.build = build;
  }

  #if js

    var node:js.html.Node;

    public function mount(node:js.html.Node) {
      this.node = context.differ.patch(node, build(this));
    }

    public function update() {
      if (node != null) {
        context.differ.patch(node, build(this));
      }
    }

  #else

    public function render() {
      Sys.print(context.render(build(this)));
    }

    public function update() {
      // noop
    }

  #end

  public function getTasks() {
    return tasks;
  }

  public function getFilteredTasks() {
    return switch filter {
      case All: tasks;
      case Filtered(status): tasks.filter(t -> t.status == status);
    }
  }

  public function setFilter(filter:TaskVisibility) {
    this.filter = filter;
    update();
  }

  public function addTask(todo:Task) {
    tasks.push(todo);
    update();
  }

  public function updateTask(task:Task, content:String) {
    task.content = content;
    update();
  }

  public function removeTask(todo:Task) {
    tasks.remove(todo);
    update();
  }

}