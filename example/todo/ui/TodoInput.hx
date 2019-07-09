package todo.ui;

import pilot.StatelessWidget;
import pilot.VNode;
import pilot.VNode.h;

class TodoInput extends StatelessWidget {

  @:prop var inputClass:String = 'edit';
  @:prop var placeholder:String = 'What needs doing?';
  @:prop var value:String;
  @:prop var save:(value:String)->Void;

  #if js
    @:prop @:optional var onAttached:()->Void;
    @:prop @:optional var onDetached:()->Void;
  #end

  override function build():VNode {
    return h('div', { className: 'todo-input' }, [
      h('input', {
        className: inputClass,
        value: value,
        placeholder: placeholder,
        #if js
          onKeyDown: e -> {
            var input:js.html.InputElement = cast e.target;
            var keyboardEvent:js.html.KeyboardEvent = cast e;
            if (keyboardEvent.key == 'Enter') {
              save(input.value);
              input.value = '';
              input.blur();
            }
          }
        #end
      })
    ]);
  }

  #if js
    override function attached(vnode:VNode) {
      if (vnode.node != null) {
        var input:js.html.InputElement = cast vnode.node;
        input.focus();
      }
      if (onAttached != null) onAttached();
    }

    override function detached() {
      if (onDetached != null) onDetached();
    }
  #end

}