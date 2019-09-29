package pilot2;

@:allow(pilot2.Differ)
class VNodeState {
  
  public final id:String;
  public final build:()->VNode;
  #if js
    var vNode:VNode;
    var differ:Differ;
  #end

  public function new(id:String, build:()->VNode) {
    this.id = id;
    this.build = build;
  }

  #if js
    
    public function mount(differ:Differ) {
      this.differ = differ;
      vNode = build();
      return vNode;
    }

    public function patch() {
      if (vNode == null || differ == null) {
        return;
      }
      differ.subPatch(vNode, build());
    }

  #end

}
