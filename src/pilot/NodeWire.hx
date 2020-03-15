package pilot;

import pilot.dom.*;

using pilot.DiffingTools;

class NodeWire<Attrs:{}> implements Wire<Attrs> {

  final node:Node;
  final isSvg:Bool;
  var attrs:Attrs;
  var types:Map<WireType<Dynamic>, WireRegistry> = [];
  var childList:Array<Wire<Dynamic>> = [];
  var context:Context;

  public function new(
    node, 
    initialAttrs:Attrs,
    context:Context,
    isSvg = false
  ) {
    this.isSvg = isSvg;
    this.node = node;
    this.context = context;
    updateAttributes(initialAttrs);
  }

  public function hydrate(context:Context) {
    if (childList.length > 0) return;

    for (n in node.childNodes) {
      var isSvg = isSvg || n.nodeName == 'svg';
      var type = isSvg ? NodeType.getSvg(n.nodeName) : NodeType.get(n.nodeName);
      var nn = new NodeWire(n, {}, context, isSvg);
      if (!types.exists(type)) {
        types.set(type, new WireRegistry());
      }
      types.get(type).put(null, nn);
      childList.push(nn);
      nn.hydrate(context);
    }
  }

  public function __getNodes():Array<Node> {
    return [ node ];
  }

  public function __getChildList():Array<Wire<Dynamic>> {
    return childList;
  }
  
  public function __setChildList(childList:Array<Wire<Dynamic>>):Void {
    this.childList = childList;
  }

  public function __getWireTypeRegistry():Map<WireType<Dynamic>, WireRegistry> {
    return types;
  }

  public function __setWireTypeRegistry(types:Map<WireType<Dynamic>, WireRegistry>):Void {
    this.types = types;
  }

  public function __setup(parent:Wire<Dynamic>, context:Context):Void {
    this.context = context;
  }
  
  public function __update(
    attrs:Attrs,
    children:Array<VNode>,
    later:Signal<Any>
  ) {
    var previousCount = node.childNodes.length;
    var cursor = getCursor();
    updateAttributes(attrs);
    var nextNodes = this.diffChildren(context, children, later);
    cursor.sync(nextNodes, previousCount);
  }

  function updateAttributes(attrs:Attrs) {
    var previous:Attrs = this.attrs;
    if (previous == null) previous = cast {};

    #if js
      syncNodeProperty(node, 'value', previous);
      syncNodeProperty(node, 'selected', previous);
      syncNodeProperty(node, 'checked', previous);
    #end

    this.attrs = attrs;
    previous.diffObject(attrs, applyAttribute);
  }

  public function __dispose() {
    this.context = null;
  }

  #if js
    inline function syncNodeProperty(node:Node, prop:String, attrs:Attrs) {
      if (js.Syntax.code('{1} in {0} && {0}[{1}]', node, prop)) {
        js.Syntax.code( '{0}[{1}] = {2}[{1}]', attrs, prop, node);
      }
    }
  #end
  
  function getCursor():Cursor {
    return new Cursor(node, node.firstChild);
  }

  #if js
    
    function applyAttribute(key:String, oldValue:Dynamic, newValue:Dynamic) {
      var el:Element = cast node;
      switch key {
        case 'value' | 'selected' | 'checked' if (!isSvg):
          js.Syntax.code('{0}[{1}] = {2}', el, key, newValue);
        // // note: this seems incorrect 
        // case 'viewBox' if (isSvg):
        //   if (newValue == null) {
        //     el.removeAttributeNS(NodeType.SVG_NS, key);
        //   } else {
        //     el.setAttributeNS(NodeType.SVG_NS, key, newValue);
        //   }
        case 'xmlns' if (isSvg):
        case 'innerHTML':
          throw 'Don\'t use `innerHTML` -- use `@dangerouslySetInnerHTML` instead';
        case _ if (!isSvg && js.Syntax.code('{0} in {1}', key, el)):
          js.Syntax.code('{0}[{1}] = {2}', el, key, newValue);
        default: 
          if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
            var ev = key.substr(2).toLowerCase();
            el.removeEventListener(ev, oldValue);
            if (newValue != null) el.addEventListener(ev, newValue);
          } else if (newValue == null || (Std.is(newValue, Bool) && newValue == false)) {
            el.removeAttribute(key);
          } else if (Std.is(newValue, Bool) && newValue == true) {
            el.setAttribute(key, key);
          } else {
            el.setAttribute(key, newValue);
          }
      }
    }

  #else

    function applyAttribute(key:String, oldValue:Dynamic, newValue:Dynamic) {
      var el:Element = cast node;
      
      if (key == 'innerHTML') {
        throw 'Don\'t use `innerHTML` -- use `@dangerouslySetInnerHTML` instead';
      }

      if (key.charAt(0) == 'o' && key.charAt(1) == 'n') {
        // noop
      } else if (newValue == null || newValue == false) {
        el.removeAttribute(key);
      } else if (newValue == true) {
        el.setAttribute(key, key);
      } else {
        el.setAttribute(key, newValue);
      }
    }

  #end

}
