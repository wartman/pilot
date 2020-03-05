Pilot Message
=============

Something like this:

- Messages send Actions to the Store.
- Models update their state from the Store and cause their connected
  Components to re-render.

```haxe

import pilot.data.*;

enum SiteAction {
  SetVisibility(visibility:TodoVisibility);
  Todo(action:TodoAction);
}

enum TodoVisibility {
  All;
  Completed;
  Pending;
}

enum TodoAction {
  CreateTodo(content:String);
  RemoveTodo(id:Int);
  UpdateTodo(id:Int, content:String);
  MarkCompleted(id:Int);
  MarkPending(id:Int);
}

class Store implements Model<SiteAction> {

  @:prop var todos:Array<Todo>;
  @:prop var visibility:TodoVisibility = All;
  @:prop var visibileTodos:Array<Todo>;

  override function update(action:SiteAction) {
    function updateVisibleTodos() 
      return todos.filter(t -> switch visibility {
        case All: true;
        case Completed: t.completed;
        case Pending: !t.completed;
      });
    return switch action {
      case SetVisibility(visibility):
        { 
          visibility: visibility,
          visibileTodos: updateVisibileTodos()
        };
      case Todo(action): switch action {
        case CreateTodo(content):
          { todos: todos.concat([ content ]) };
        case RemoveTodo(id):
          { todos: todos.filter(t -> t.id != id) };
        default:
          for (todo in todos) todo.update(action);
          return {
            visibileTodos: updateVisibileTodos()
          };
      }
    }
  }

}

class Todo implements Model<TodoAction> {

  @:prop var id:Int;
  @:prop var content:String;
  @:prop var completed:Bool = false;

  override function update(action:TodoAction) return switch action {
    case UpdateTodo(checkId, content) if (id == checkId):
      { content: content };
    case MarkCompleted(checkId) if (checkId == id && !completed):
      { completed: true };
    case MarkPending(checkId) if (checkId == id && completed):
      { completed: false };
    default:
      null; 
  }

}

```
