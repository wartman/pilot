package pilot.diff;

import haxe.DynamicAccess;

class Differ<Real:{}> {

  static final EMPTY = {};

  inline public static function patchObject(
    oldProps:DynamicAccess<Dynamic>,
    newProps:DynamicAccess<Dynamic>,
    apply:(key:String, oldValue:Dynamic, newValue:Dynamic)->Void
  ) {
    if (oldProps == newProps) return;

    var keys = (if (newProps == null) {
      newProps = EMPTY;
      oldProps;
    } else if (oldProps == null) {
      oldProps = EMPTY;
      newProps;
    } else {
      var ret = newProps.copy();
      for (key in oldProps.keys()) ret[key] = true;
      ret;
    }).keys();

    for (key in keys) switch [ oldProps[key], newProps[key] ] {
      case [ a, b ] if (a == b):
      case [ a, b ]: apply(key, a, b);
    } 
  }
  
  final context:Context<Real>;

  public function new(context) {
    this.context = context;
  }

  // todo: DRY this up
  public function patchRoot(?root:Real, node:VNode<Real>):Real {
    var previous = root == null
      ? new RenderResult(null, [], [])
      : context.getPreviousRender(root);
    var result:RenderResult<Real> = new RenderResult(null, [], []);

    root = switch node {
      case VNative(type, attrs, children, _): switch previous.root {
        case null:
          var node = type.create(attrs);
          result = patch(node, children);
          result.root = RNative(node, attrs);
          node;
        case RNative(node, oldAttrs):
          type.update(node, cast oldAttrs, attrs);
          result = patch(node, children);
          result.root = RNative(node, attrs);
          node;
        default:
          throw 'assert';
      }

      case VWidget(type, attrs, _): switch previous.root {
        case null:
          var w = type._pilot_create(attrs);
          w._pilot_init(this);
          result.root = RWidget(w);
          w._pilot_real;
        case RWidget(w):
          w._pilot_update(attrs);
          result.root = RWidget(w);
          w._pilot_real;
        default:
          throw 'assert';
      }

      case VFragment(_):
        throw 'Fragment not allowed as a root';
    }
    
    previous.dispose();
    context.setPreviousRender(root, result);
    return root;
  }

  public function patch(parent:Real, nodes:Array<VNode<Real>>):RenderResult<Real> {
    var previous = context.getPreviousRender(parent);
    var result:RenderResult<Real> = new RenderResult(null, [], []);

    function process(nodes:Array<VNode<Real>>) for (n in nodes) switch n {

      case null:

      case VNative(type, attrs, children, key): switch previous.resolve(type, key) {
        case null:
          var el = type.create(attrs);
          context.addChild(parent, el);
          if (children.length > 0) patch(el, children);
          result.set(type, key, RNative(el, attrs));
        case RNative(node, oldAttrs):
          type.update(node, cast oldAttrs, attrs);
          if (children.length > 0) patch(node, children);
          result.set(type, key, RNative(node, attrs));
        default:
          // todo?
      }

      case VWidget(type, attrs, key): switch previous.resolve(type, key) {
        case null:
          var w = type._pilot_create(attrs);
          w._pilot_init(this);
          context.addChild(parent, w._pilot_real);
          result.set(type, key, RWidget(w));
        case RWidget(w):
          w._pilot_update(attrs);
          result.set(type, key, RWidget(w));
        default:

      }

      case VFragment(children):
        process(children);

    }

    process(nodes);
    
    if (previous.remaining()) {
      function remove(n:RNode<Real>) switch n {
        case RNative(node, _):
          context.removePreviousRender(node, true);
          context.removeChild(parent, node);
        case RWidget(widget):
          context.removePreviousRender(widget._pilot_real, true);
          context.removeChild(parent, widget._pilot_real);
          widget.dispose();
      }
      for (n in previous.childList) remove(n);
    }

    context.removePreviousRender(parent);
    context.setPreviousRender(parent, result);
    
    return result;
  }

}
