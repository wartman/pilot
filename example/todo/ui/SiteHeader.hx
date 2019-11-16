package todo.ui;

import pilot.RenderResult;
import Pilot.html;
import todo.data.*;

abstract SiteHeader(RenderResult) to RenderResult {
  
  public function new(props:{
    store:Store
  }) {
    this = html(<header class="todo-header">
      <h1 class@style={
        position: absolute;
        top: -155px;
        width: 100%;
        font-size: 100px;
        font-weight: 100;
        text-align: center;
        color: rgba(175, 47, 47, 0.15);
        -webkit-text-rendering: optimizeLegibility;
        -moz-text-rendering: optimizeLegibility;
        text-rendering: optimizeLegibility;
      }>todos</h1>
      <TodoInput
        inputClass="new-todo"
        value=""
        save={value -> props.store.addTodo(new Todo(value))}
      />
    </header>);    
  }

}
