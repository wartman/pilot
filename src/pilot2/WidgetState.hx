package pilot2;

// This seems to leak like mad?

@:allow(pilot2.Differ)
class WidgetState<T:Widget> {
  
  var widget:T;
  #if js
    var vNode:VNode;
    var differ:Differ;
  #end

  public function new(widget:T) {
    this.widget = widget;
  }

  public function build() {
    return widget.build();
  }

  #if js
    
    public function mount(differ:Differ, vNode:VNode) {
      this.differ = differ;
      this.vNode = vNode;
    }

    public function patch() {
      if (vNode == null || differ == null) {
        return;
      }
      differ.subPatch(vNode, build());
    }

  #end

}
