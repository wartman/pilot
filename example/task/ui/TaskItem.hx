package task.ui;

import pilot2.VNode;
import pilot2.Widget;
import task.data.*;
import task.ui.pattern.Card;

class TaskItem extends Widget {
  
  @:prop var store:Store;
  @:prop var task:Task;
  @:prop.state var isEditing:Bool = false;

  override function build():VNode {
    return if (isEditing) new TaskEditor({
      id: 'edit_${task.id}',
      value: task.content,
      #if js
        onSave: value -> {
          store.updateTask(task, value);
        },
        requestClose: () -> isEditing = false
      #end
    }) else new Card({
      // key: 'edit_${task.id}',
      children: [
        new VNode({ name: 'p', children: [ task.content ] }),
        new VNode({
          name: 'button',
          props: {
            #if js
              onClick: e -> isEditing = true
            #end
          },
          children: [ 'Edit' ]
        })
      ]
    });
  }

}
