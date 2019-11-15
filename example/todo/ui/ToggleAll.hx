package todo.ui;

import pilot.RenderResult;
import Pilot.html;

abstract ToggleAll(RenderResult) to RenderResult {
  
  public function new(props:{
    checked:Bool,
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
      class@style={

        width: 1px;
        height: 1px;
        border: none; /* Mobile Safari */
        opacity: 0;
        position: absolute;
        right: 100%;
        bottom: 100%;

        & + label {
          width: 60px;
          height: 34px;
          font-size: 0;
          position: absolute;
          top: -52px;
          left: -13px;
          -webkit-transform: rotate(90deg);
          transform: rotate(90deg);
        }

        & + label:before {
          content: "❯";
          font-size: 22px;
          color: #e6e6e6;
          padding: 10px 27px 10px 27px;
        }

        &:checked + label:before {
          color: #737373;
        }

        /*
        Hack to remove background from Mobile Safari.
        Can't use it globally since it destroys checkboxes in Firefox
        */
        @media screen and (-webkit-min-device-pixel-ratio:0) {
          background: none;
        }
        
      }
    />);
  }

}