package task.ui;

import pilot2.VNode;
import pilot2.Style;
import pilot2.Widget;
import task.data.*;

class SiteHeader extends Widget {

  @:prop var store:Store;
  @:prop.state var isEditing:Bool = false;

  override function build():VNode {
    return new VNode({
      name: 'header',
      style: Style.create({
        
      }),
      children: [
        new VNode({ name: 'h1', children: [ 'Tasks' ] }),
        new VNode({
          name: 'ul',
          children: [
            new VNode({
              name: 'li',
              children: [
                if (isEditing) new TaskEditor({
                  id: 'add',
                  value: '',
                  #if js
                    requestClose: () -> isEditing = false,
                    onSave: value -> store.addTask(Task.create(value))
                  #end
                }) else new VNode({
                  name: 'button',
                  props: { 
                    #if js
                      onClick: _ -> isEditing = true
                    #end
                  },
                  children: [ 'Add Task' ]
                })
              ]
            })
          ]
        })
      ]
    });
  }

}