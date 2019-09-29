package pilot2;

/**
  Right now this is mostly a way to pass a Differ or
  a Renderer around, but it might get more complex later.

  It's also the entry point for any app, where you boot
  things up with Context.mount() or Context.render().
**/
class Context {

  public final hooks:HookManager = [];

  #if js
  
    public final differ:Differ;
    
    public function new() {
      differ = new Differ(this);
    }
    
    public function mount(node:js.html.Node, vNode:VNode) {
      differ.patch(node, vNode);
    }
  
  #else

    public final renderer:Renderer;

    public function new() {
      renderer = new Renderer(this);
    }

    public function render(vNode:VNode) {
      Sys.print(renderer.render(vNode));
    }

  #end

}
