package todo.ui;

import pilot.PureComponent;
import pilot.Template.html;

abstract Toggle(PureComponent) to PureComponent {

  public function new(props:{
    checked:Bool,
    // type:ToggleType,
    ?id:String,
    #if js
      onClick:(e:js.html.Event)->Void
    #end
  }) {
    this = html(<input 
      type="checkbox"
      checked={props.checked}
      id={props.id}
      onClick={props.onClick}
    />);
  }

}

// import pilot.Style;
// import pilot.VNode;

// enum ToggleType {
//   One;
//   All;
// }

// abstract Toggle(VNode) to VNode {

//   static final toggles = Style.sheet({
//     toggleOne: {
//       'text-align': 'center',
//       width: '40px',
//       /* auto, since non-WebKit browsers doesn't support input styling */
//       height: 'auto',
//       position: 'absolute',
//       top: 0,
//       bottom: 0,
//       margin: 'auto 0',
//       border: 'none', /* Mobile Safari */
//       '-webkit-appearance': 'none',
//       appearance: 'none',
//       opacity: 0,

//       '& + label': { 
//         'background-image': "url('data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A//www.w3.org/2000/svg%22%20width%3D%2240%22%20height%3D%2240%22%20viewBox%3D%22-10%20-18%20100%20135%22%3E%3Ccircle%20cx%3D%2250%22%20cy%3D%2250%22%20r%3D%2250%22%20fill%3D%22none%22%20stroke%3D%22%23ededed%22%20stroke-width%3D%223%22/%3E%3C/svg%3E')",
//         'background-repeat': 'no-repeat',
//         'background-position': 'center left',
//       },

//       '&:checked + label': {
//         'background-image': "url('data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A//www.w3.org/2000/svg%22%20width%3D%2240%22%20height%3D%2240%22%20viewBox%3D%22-10%20-18%20100%20135%22%3E%3Ccircle%20cx%3D%2250%22%20cy%3D%2250%22%20r%3D%2250%22%20fill%3D%22none%22%20stroke%3D%22%23bddad5%22%20stroke-width%3D%223%22/%3E%3Cpath%20fill%3D%22%235dc2af%22%20d%3D%22M72%2025L42%2071%2027%2056l-4%204%2020%2020%2034-52z%22/%3E%3C/svg%3E')",
//       },
      
//       '@media screen and (-webkit-min-device-pixel-ratio:0)': {
//         '&': {
//           background: 'none',
//           height: '40px'
//         }
//       }
//     },
//     toggleAll: {
//       width: '1px',
//       height: '1px',
//       border: 'none', /* Mobile Safari */
//       opacity: 0,
//       position: 'absolute',
//       right: '100%',
//       bottom: '100%',
//       '& + label': {
//         width: '60px',
//         height: '34px',
//         'font-size': 0,
//         position: 'absolute',
//         top: '-52px',
//         left: '-13px',
//         '-webkit-transform': 'rotate(90deg)',
//         transform: 'rotate(90deg)',
//       },
//       '& + label:before': {
//         content: '"❯"',
//         'font-size': '22px',
//         color: '#e6e6e6',
//         padding: '10px 27px 10px 27px',
//       },
//       '&:checked + label:before': {
//         color: '#737373'
//       },
//       /*
//       Hack to remove background from Mobile Safari.
//       Can't use it globally since it destroys checkboxes in Firefox
//       */
//       '@media screen and (-webkit-min-device-pixel-ratio:0)': {
//         '&': {
//           background: 'none'
//         }
//       }
//     }
//   });
  
//   public inline function new(props:{
//     checked:Bool,
//     type:ToggleType,
//     ?id:String,
//     #if js
//       onClick:(e:js.html.Event)->Void
//     #end
//   }) {
//     this = new VNode({
//       name: 'input',
//       style: [
//         switch props.type {
//           case One: toggles.toggleOne;
//           default: toggles.toggleAll;
//         }
//       ],
//       props: {
//         type: 'checkbox',
//         checked: props.checked,
//         id: props.id,
//         #if js
//           onClick: props.onClick,
//         #end
//       },
//       children: []
//     });
//   }

// }