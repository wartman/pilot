Pilot Message
=============

Something like this:

- Messages send Actions to the Store.
- Models update their state from the Store and cause their connected
  Components to re-render.

```haxe

import pilot.data.*;

class Todo implements Model {
    @:prop var id:Int;
    @:prop var content:String;
    @:prop var completed:Bool = false;
}

enum TodoAction {
    CreateTodo(content:String);
    RemoveTodo(id:Int);
    UpdateTodo(id:Int, content:String);
}


```
