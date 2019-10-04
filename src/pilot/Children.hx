package pilot;

import pilot.VNode;

using Lambda;

abstract Children(Array<VNode>) from Array<VNode> to Array<VNode> {
  
  @:from public static inline function ofVNode(vn:VNode):Children {
    return [ vn ];
  }

  @:to public inline function toVNode():VNode {
    return VNode.ofArray(this);
  }

  public inline function addChild(vn:VNode):Children {
    this.push(vn);
    return this;
  }

  public inline function addChildren(children:Array<VNode>):Children {
    for (c in children) this.push(c);
    return this;
  }

  public inline function removeChild(vn:VNode):Children {
    this.remove(vn);
    return this;
  }

  public inline function findChild(f:(vn:VNode)->Bool):VNode {
    return this.find(f);
  }

}
