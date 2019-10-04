package task.ui;

import pilot.VNode;
import pilot.Widget;
import task.ui.pattern.Card;

class TaskEditor extends Widget {
  
  @:prop var id:String;
  @:prop var value:String;

  #if js

    @:prop var requestClose:()->Void;
    @:prop var onSave:(value:String)->Void;
    var inputNode:js.html.InputElement;

  #end

  override function build():VNode {
    #if js
      function clickOff() {
        trace('click');
        requestClose();
        js.Browser.document.removeEventListener('click', clickOff);
      }
    #end
    return new Card({
      // key: id,
      #if js
        onClick: e -> e.stopPropagation(),
        hooks: [
          HookDestroy(_ -> js.Browser.document.removeEventListener('click', clickOff)),
          HookInsert(_ -> js.Browser.document.addEventListener('click', clickOff))
        ],
      #end
      children: [
        new VNode({
          name: 'input',
          #if js
            hooks: [
              HookInsert(vn -> {
                // trace('input insert');
                inputNode = cast vn.node;
                // trace(inputNode); 
                inputNode.focus();
              })
            ],
          #end
          props: { 
            type: 'text',
            name: id,
            id: id, 
            value: value,
            #if js
              onKeydown: (e:js.html.KeyboardEvent) -> {
                if (e.key == 'Enter') {
                  var input:js.html.InputElement = cast e.target;
                  onSave(input.value);
                } else if (e.key == 'Escape') {
                  requestClose();
                }
              }
            #end
          }
        }),
        new VNode({
          name: 'button',
          props: {
            #if js
              onClick: _ -> onSave(inputNode.value),
            #end
          },
          children: [ 'Save' ]
        }),
        new VNode({
          name: 'button',
          props: {
            #if js
              onClick: _ -> requestClose(),
            #end
          },
          children: [ 'Cancel' ]
        })
      ]
    });
  }

}
