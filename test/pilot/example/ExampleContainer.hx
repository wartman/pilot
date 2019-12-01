package pilot.example;

import pilot.VNode;

abstract ExampleContainer(VNode) to VNode {

  public function new(props:{
    title:String,
    children:Children
  }) {
    this = Pilot.html(<li>
      <h3>{props.title}</h3>
      {props.children}
    </li>);
  }

}
