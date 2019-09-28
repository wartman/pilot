package pilot2;

@:allow(pilot2.Differ)
class WidgetState<T:WidgetLike> {
  
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
