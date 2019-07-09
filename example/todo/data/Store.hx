package todo.data;

import pilot.VNode;

#if js
  using pilot.Differ;
#else
  using pilot.Renderer;
#end

class Store {

  var todos:Array<Todo> = [];
  final build:(store:Store)->VNode;
  public var filter:VisibleTodos = VisibleAll;
  public var visibleTodos(get, never):Array<Todo>;
  inline function get_visibleTodos() {
    var filtered = switch filter {
      case VisibleAll: todos;
      case VisibleCompleted: todos.filter(todo -> todo.complete);
      case VisiblePending: todos.filter(todo -> !todo.complete);
    }
    filtered.reverse();
    return filtered;
  }
  public var remainingTodos(get, never):Int;
  inline function get_remainingTodos() return todos.filter(todo -> !todo.complete).length;

  #if js
    final node:js.html.Node;

    public function new(build, node) {
      this.node = node;
      this.build = build;
    }
    
    public function update() {
      node.patch(build(this));
    }

  #else
    public function new(build) {
      this.build = build;
    }

    public function update() {
      Sys.print(build(this).render());
    }
  #end

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

}
