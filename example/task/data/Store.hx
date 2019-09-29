package task.data;

import pilot2.VNode;

class Store {

  final tasks:Array<Task>;
  final build:(store:Store)->VNode;

  public function new(tasks, build) {
    this.tasks = tasks;
    this.build = build;
  }

  #if js

    var state:pilot2.VNodeState;

    public function mount(node:js.html.Node) {
      var differ = new pilot2.Differ();
      state = new pilot2.VNodeState('root', () -> build(this));
      differ.patch(node, state);
    }

    public function update() {
      if (state != null) state.patch();
    }

  #else

    public function render() {
      Sys.print(pilot2.Renderer.render(build(this)));
    }

    public function update() {
      // noop
    }

  #end

}