package pilot;

import haxe.ds.Map;

class Context {

  final data:Map<String, Dynamic>;
  final parent:Context;
  final renderQueue:Array<()->Void> = [];

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

  public function getChild() {
    return new Context([], this);
  }

  public function enqueueRender(update:()->Void) {
    if (parent != null) {
      // Ensure only the root context enqueues rendering.
      parent.enqueueRender(update);
      return;
    }
    if (renderQueue.push(update) == 1) {
      scheduleRenderQueueProcessing();
    }
  }

  // this probably isn't working right -- look into a real debounce function.
  function scheduleRenderQueueProcessing() {
    var later = new Signal<Any>();
    later.addOnce(_ -> {
      var update;
      while ((update = renderQueue.pop()) != null) update();
    });
    later.enqueue(null);
  }
  
}
