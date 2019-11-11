package todo.ui;

import pilot.PureComponent;
import Pilot.html;
import todo.data.*;

abstract SiteFooter(PureComponent) to PureComponent {
  
  public function new(props:{
    store:Store
  }) {
    this = html(<footer class@style={
      
      padding: 10px 15px;
      height: 20px;
      text-align: center;
      font-size: 15px;
      border-top: 1px solid #e6e6e6;

      &:before {
        content: '';
        position: absolute;
        right: 0;
        bottom: 0;
        left: 0;
        height: 50px;
        overflow: hidden;
        box-shadow: 0 1px 1px rgba(0, 0, 0, 0.2),
                    0 8px 0 -3px #f6f6f6,
                    0 9px 1px -3px rgba(0, 0, 0, 0.2),
                    0 16px 0 -6px #f6f6f6,
                    0 17px 2px -6px rgba(0, 0, 0, 0.2);
      }

      @media (max-width: 430px) {
        height: 50px;
      }

    }>
      <span class@style={
        float: left;
        text-align: left;
      }>{remaining(props.store)}</span>
      <ul class@style={

        margin: 0;
        padding: 0;
        list-style: none;
        position: absolute;
        right: 0;
        left: 0;
        
        @media (max-width: 430px) {
          bottom: 10px;
        }

        li {
          display: inline;
          a {
            color: inherit;
            margin: 3px;
            padding: 3px 7px;
            text-decoration: none;
            border: 1px solid transparent;
            border-radius: 3px;
            &:hover {
              border-color: rgba(175, 47, 47, 0.1);
            }
            &.selected {
              border-color: rgba(175, 47, 47, 0.2);
            }
          }
        }

      }>
        <li>
          <a 
            href="#all"
            class={getSelected(props.store, VisibleAll)}
            onClick={e -> setFilter(props.store, e, VisibleAll)}
          >All</a>
        </li>
        <li>
          <a 
            href="#pending"
            class={getSelected(props.store, VisiblePending)}
            onClick={e -> setFilter(props.store, e, VisiblePending)}
          >Pending</a>
        </li>
        <li>
          <a 
            href="#completed"
            class={getSelected(props.store, VisibleCompleted)}
            onClick={e -> setFilter(props.store, e, VisibleCompleted)}
          >Completed</a>
        </li>
      </ul>
      <button 
        class@style={
          float: right;
          position: relative;
          line-height: 20px;
          text-decoration: none;
          cursor: pointer;
        }
        onClick={_ -> props.store.clearCompleted()}
      >Clear completed</button>
    </footer>);
  }
  
  static function remaining(store:Store) {
    return switch store.remainingTodos {
      case 0: 'No items left';
      case 1: '1 item left';
      case remaining: '${remaining} items left';
    }
  }

  static function getSelected(store:Store, filter:VisibleTodos) {
    return store.filter == filter ? 'selected' : null;
  }

  #if js
    static function setFilter(store:Store, e:js.html.Event, filter:VisibleTodos) {
      e.preventDefault();
      store.setFilter(filter);
    }
  #end

}
