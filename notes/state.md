State
=====
This is a simple, redux-style system we can use for state management.

It'll look something like this:

```haxe

class FooState extends State {

  @:attribute var foo:String;

  @:transition
  public function setFoo(foo:String) {
    return { foo: foo };
  }

}

class Content extends Component {

  override function render() {
    return html(
      <FooState foo="bar">
        <ChildComp />
      </FooState>
    );
  }

}

class ChildComp extends Component {

  // Will check the current context for `FooState.__stateId` via
  // a macro?
  @:attribute( consume ) var foo:FooState

  override function render() {
    return html(<>
      <p>{foo.foo}</p>
      <button onClick={_ -> foo.setFoo('foo')}>Make Foo</button>
    </>);
  }

}

```

Ideally, this will replace the current Provider idea with something a bit more type-safe.

Here's some thinking about how it might be used for something like TodoMVC (just for a more real implementation):

```haxe
package todo;

import pilot.State;

enum TodoFilter {
  FilterAll;
  FilterCompleted;
  FilterPending;
}

typedef Todo = {
  public var id:Int;
  public var content:String;
  public var completed:Bool;
}

class TodoState extends State {

  @:attribute var todos:Array<Todo>;
  @:attribute var filter:TodoFilter;
  @:computed var visibleTodos = todos.filter(todo -> switch filter {
    case FilterAll: true;
    case FilterCompleted: todo.completed;
    case FilterPending: !todo.completed;
  });
  var ids:Int = 0;

  @:transition
  public function setFilter(filter:TodoFilter) {
    return { filter: filter };
  }

  @:transition
  public function addTodo(content:String) {
    return {
      todos: todos.concat([ {
        id: ids++,
        content: content,
        completed: false
      } ]),
      filter: FilterAll
    };
  }

  @:transition
  public function removeTodo(todo:Todo) {
    return {
      todos: todos.filter(t -> t.id != todo.id)
    };
  }

}
```

... and the UI would look something like:

```haxe
package todo;

import pilot.Component;
import todo.TodoState;

class TodoItem extends Component {

  @:attribute(consume) var todos:TodoState;
  @:attribute var todo:Todo;

  override function render() return html(<li>
    <p>{todo.content}</p>
    <button onClick={_ -> todos.removeTodo(todo)}>Remove</button>
  </li>);

}

```

Other things to consider: sub-states and composition. How might we handle that?

Also, we might want to include models? They could be simple things, like this:

```haxe
package todo;

import pilot.Model;

class Todo implements Model {
  @:prop var id:Int;
  @:prop var content:String;
  @:prop var completed:Bool;
}

```

This would do nothing except provide a constructor for us (along with maybe computed props).
