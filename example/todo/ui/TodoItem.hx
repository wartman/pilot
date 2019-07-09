package todo.ui;

#if js
  import js.Browser;
#end
import pilot.StatefulWidget;
import pilot.VNode;
import pilot.VNode.h;
import todo.data.Todo;
import todo.data.Store;

class TodoItem extends StatefulWidget {

  @:prop var todo:Todo;
  @:prop var store:Store;
  @:state var editing:Bool = false;

  override function build():VNode {
    return switch editing {
      case true: h('li', {
        className: 'todo-item editing',
        key: todo.id,
        id: 'Todo-${todo.id}',
        #if js
          onClick: e -> e.stopPropagation()
        #end
      },  [
        new TodoInput({
          value: todo.content,
          #if js
            onAttached: () -> {
              function clickOffListener(e) {
                trace('click');
                editing = false;
                Browser.window.removeEventListener('click', clickOffListener);
              }
              Browser.window.addEventListener('click', clickOffListener);
            },
          #end
          save: value -> {
            store.updateTodo(todo, value);
            editing = false;
          }
        })
      ]);
      case false: h('li', {
        key: todo.id,
        id: 'Todo-${todo.id}',
        className: 'todo-item',
        #if js
          onDblClick: e -> editing = true
        #end
      }, [
        h('input', {
          type: 'checkbox',
          className: 'toggle',
          checked: todo.complete,
          #if js
            onClick: e -> switch todo.complete {
              case true: store.markPending(todo);
              case false: store.markComplete(todo);
            }
          #end
        }),
        h('label', {}, [ todo.content ]),
        h('button', {
          className: 'destroy',
          #if js
            onClick: e -> store.removeTodo(todo)
          #end
        })
      ]);
    }
  }

}