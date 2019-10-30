package pilot2.diff;

import haxe.ds.Map;

typedef RenderResultImpl<Real:{}> = {
  root:RNode<Real>,
  typeList:Map<{}, Array<RNode<Real>>>,
  childList:Array<RNode<Real>>
} 

@:forward
abstract RenderResult<Real:{}>(RenderResultImpl<Real>) from RenderResultImpl<Real> to RenderResultImpl<Real> {

  inline public function new(root, typeList, childList) {
    this = {
      root: root,
      typeList: typeList,
      childList: childList
    };
  }

  public function add(type:{}, node:RNode<Real>) {
    if (!this.typeList.exists(type)) {
      this.typeList.set(type, []);
    }
    this.typeList.get(type).push(node);
    this.childList.push(node);
  }

  public function pull(type) {
    var nodes = this.typeList.get(type);
    if (nodes == null) return null;

    var n = nodes.shift();
    this.childList.remove(n);
    return n;
  }

  public function set(type:{}, key:Null<Key>, node:RNode<Real>) {
    if (key != null) {
      add(type, RKeyed(key, node));
    } else {
      add(type, node);
    }
  }

  public function remaining() {
    return this.childList.length > 0;
  }

  public function resolve(type:{}, ?key:Key) {
    var nodes = this.typeList.get(type);
    if (nodes == null) return null;
    for (n in nodes) switch n {
      case RKeyed(k, _) if (k == key):
        nodes.remove(n); 
        this.childList.remove(n);
        return n;
      default:
    }
    return pull(type);
  }

  public function dispose() {
    this.root = null;
    this.typeList = null;
    this.childList = null;
  }

}
