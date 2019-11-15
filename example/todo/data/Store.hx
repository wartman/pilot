package todo.data;

import pilot.RenderResult;
import pilot.Root;

class Store {

  var todos:Array<Todo> = [];
  final build:(store:Store)->RenderResult;
  public var filter:VisibleTodos = VisibleAll;
  
  var _allSelected:Bool = null;
  public var allSelected(get, never):Bool;
  public function get_allSelected() {
    if (_allSelected != null) return _allSelected;
    if (visibleTodos.length == 0) {
      _allSelected = false;
      return _allSelected;
    }
    _allSelected = visibleTodos.filter(t -> !t.complete).length == 0;
    return _allSelected;
  }

  var _visibleTodos:Array<Todo> = null;
  public var visibleTodos(get, never):Array<Todo>;
  inline function get_visibleTodos() {
    if (_visibleTodos != null) return _visibleTodos;
    var filtered = todos.copy();
    filtered.reverse();
    _visibleTodos = switch filter {
      case VisibleAll: filtered;
      case VisibleCompleted: filtered.filter(todo -> todo.complete);
      case VisiblePending: filtered.filter(todo -> !todo.complete);
    }
    return _visibleTodos;
  }
  public var remainingTodos(get, never):Int;
  inline function get_remainingTodos() return todos.filter(todo -> !todo.complete).length;

  final root:Root;

  public function new(build, node) {
    this.root = new Root(node);
    this.build = build;
  }
  
  public function update() {
    _visibleTodos = null;
    _allSelected = null;
    root.update(build(this));
  }

  public function getTodos() {
    return todos;
  }

  public function addTodo(todo:Todo) {
    todos.push(todo);
    update();
  }

  public function updateTodo(todo:Todo, content:String) {
    todo.content = content;
    update();
  }

  public function removeTodo(todo:Todo) {
    todos.remove(todo);
    update();
  }

  public function setFilter(filter:VisibleTodos) {
    this.filter = filter;
    update();
  }

  public function markAllComplete() {
    for (todo in visibleTodos) todo.complete = true;
    update();
  }

  public function markAllPending() {
    for (todo in visibleTodos) todo.complete = false;
    update();
  }

  public function markComplete(todo:Todo) {
    if (todo.complete) return;
    todo.complete = true;
    update();
  }
  
  public function markPending(todo:Todo) {
    if (!todo.complete) return;
    todo.complete = false;
    update();
  }

  public function clearCompleted() {
    var toRemove = visibleTodos.filter(t -> t.complete);
    if (toRemove.length == 0) return;
    for (t in toRemove) {
      todos.remove(t);
    }
    update();
  }

}
