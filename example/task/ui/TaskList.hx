package task.ui;

import pilot.*;
import task.data.*;
import task.ui.pattern.*;

class TaskList extends Widget {
  
  @:prop var store:Store;
  @:prop.state var isAdding:Bool = false;

  override function build():VNode {
    return new VNode({
      name: 'div',
      style: Style.create({
        display: 'flex',
        flexDirection: 'column',
        width: '100%',
      }),
      children: [
        new VNode({
          name: 'div',
          children: [        
            if (isAdding) new TaskEditor({
              id: 'add',
              #if js
                requestClose: () -> isAdding = false,
                onSave: value -> store.addTask(Task.create(value)),
              #end
              value: ''
            }) else new Card({
              // key: 'add',
              children: [
                new VNode({
                  name: 'button',
                  props: {
                    #if js
                      onClick: e -> isAdding = true 
                    #end
                  },
                  children: [ 'Add Task' ]
                })
              ]
            })
          ]
        }),

        new VNode({
          name: 'div',
          children: [ for (task in store.getFilteredTasks()) 
            new TaskItem({ task: task, store: store })
          ]
        })
      ]
    });
  }

}