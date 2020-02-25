package pilot;

import haxe.ds.Map;

class Context {

  final data:Map<String, Dynamic>;
  final parent:Context;
  var renderQueue:Map<Wire<Dynamic>, ()->Void>;

  public function new(?initialData, ?parent) {
    data = if (initialData != null) initialData else [];
    this.parent = parent;
  }

  public function get<T>(name:String, ?def:T):T {
    return if (data.exists(name)) 
      data.get(name)
    else if (parent != null)
      parent.get(name, def); 
    else 
      def;
  }

  inline public function set<T>(name:String, value:T) {
    data.set(name, value);
  }

  inline public function remove(name:String) {
    data.remove(name);
  }

  public function copy() {
    return new Context([], this);
  }

  public function enqueueRender(wire:Wire<Dynamic>, update:()->Void) {
    if (parent != null) {
      // Ensure only the root context enqueues rendering.
      parent.enqueueRender(wire, update);
      return;
    }
    if (renderQueue == null) scheduleRenderQueueProcessing();
    renderQueue.set(wire, update);
  }

  function scheduleRenderQueueProcessing() {
    renderQueue = [];
    var later = new Later();
    later.add(() -> {
      for (_ => update in renderQueue) update();
      renderQueue = null;
    });
    later.enqueue();
  }

}
