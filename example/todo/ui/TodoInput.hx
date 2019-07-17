package todo.ui;

import pilot.StatelessWidget;
import pilot.StyledWidget;
import pilot.Style;
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
    return new StyledWidget({
      style: Style.create({
        
        input: {
          position: 'relative',
          margin: 0,
          width: '100%',
          'font-size': '24px',
          'font-family': 'inherit',
          'font-weight': 'inherit',
          'line-height': '1.4em',
          color: 'inherit',
          padding: '6px',
          border: '1px solid #999',
          'box-shadow': 'inset 0 -1px 5px 0 rgba(0, 0, 0, 0.2)',
          'box-sizing': 'border-box',
          '-webkit-font-smoothing': 'antialiased',
          '-moz-osx-font-smoothing': 'grayscale',
        },

        '.new-todo': {
          padding: '16px 16px 16px 60px',
          border: 'none',
          background: 'rgba(0, 0, 0, 0.003)',
          'box-shadow': 'inset 0 -2px 1px rgba(0,0,0,0.03)',
        },

      }),
      child: h('div', { className: 'todo-input' }, [
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
      ])
    });
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