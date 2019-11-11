#if macro
package pilot.dsl;

import haxe.macro.Context;
import haxe.macro.Expr;
import pilot.dsl.MarkupNode;

using StringTools;
using haxe.macro.PositionTools;

class MarkupGenerator {
  
  static final attributeMacros:Map<String, (attr:MarkupAttribute, pos:Position)->ObjectField> = [
    'style' => (attr, pos) -> {
      field: attr.name,
      expr: switch attr.value.value {
        case Raw(_):
          throw new DslError('@style does not accept raw values', attr.pos);
        case Code(value):
          Css.parse(macro @:pos(pos) $v{value});
      }
    },
    'style-embed' => (attr, pos) -> {
      field: attr.name,
      expr: switch attr.value.value {
        case Raw(_):
          throw new DslError('@style does not accept raw values', attr.pos);
        case Code(value):
          Css.parse(macro @:pos(pos) $v{value}, true);
      }
    }
  ];

  static public function registerMacro(name, handler) {
    attributeMacros.set(name, handler);
  }
  
  final nodes:Array<MarkupNode>;
  final pos:Position;

  public function new(nodes, pos) {
    this.nodes = nodes;
    this.pos = pos;
    // todo: allow custom macros
  }

  public function generate():Expr {
    var exprs:Array<Expr> = [ for (node in nodes)
      generateNode(node)
    ].filter(e -> e != null);
    var eType = exprs.length == 1 ? exprs[0] : macro VFragment([ $a{exprs} ]);

    return macro @:pos(pos) (${eType}:pilot.core.VNode<pilot.RealNode>);
  }

  function generateNode(node:MarkupNode):Expr {
    if (node == null) return null;
    var pos = makePos(node.pos);
    return switch node.node {

      case MNode(name, attrs, children, false):
        var key = extractKey(attrs);
        var fields = generateAttrs(attrs);
        var type = generateNodeType(name, pos);

        var attrs:Expr = {
          expr: EObjectDecl(fields),
          pos: pos
        };
        var children:Array<Expr> = children == null ? [] : [ for (c in children)
          generateNode(c)
        ].filter(e -> e != null);
        
        macro @:pos(pos) VNative(
          ${type}, 
          ${attrs}, 
          [ $a{children} ],
          ${key}  
        );
        
      case MNode(name, attrs, children, true):
        var tp = if (name.contains('.')) {
          var pack = name.split('.');
          var clsName = pack.pop();
          { pack: pack, name: clsName };
        } else { pack: [], name: name };
        var type = try {
          Context.getType(name);
        } catch(e:String) {
          Context.error(e, pos);
        }
        
        var key = extractKey(attrs);
        var fields = generateAttrs(attrs);

        if (children != null && children.length > 0) {
          var exprs = [ for (c in children) generateNode(c) ].filter(e -> e != null);
          fields.push({
            field: 'children',
            expr: macro @:pos(pos) [ $a{exprs} ]
          });
        }
        var attrs:Expr = {
          expr: EObjectDecl(fields),
          pos: pos
        };

        if (Context.unify(type, Context.getType('pilot.core.VNode'))) {
          macro @:pos(pos) new $tp($attrs);
        } else {
          if (!Context.unify(type, Context.getType('pilot.core.Component'))) {
            Context.error('Components must implement pilot.core.Component', pos);
          }
          macro @:pos(pos) VComponent(
            $p{tp.pack.concat([ tp.name ])},
            ${attrs},
            ${key}
          );
        }

      case MCode(v):
        var e = Context.parse(v, pos);
        var t = Context.typeof(e);
        if (Context.unify(t, Context.getType('pilot.Children'))) {
          macro @:pos(pos) VFragment(${e});
        } else {
          macro @:pos(pos) VNative(${generateNodeType('text', pos)}, ${e}, []);
        }

      case MText(value):
        macro @:pos(pos) VNative(${generateNodeType('text', pos)}, $v{value}, []);

      case MFor(it, children):
        switch Context.parse(it, pos) {
          case macro $i{name} in $target:
            var body = generateChildren(children, pos);
            macro @:pos(pos) VFragment([ for ($i{name} in ${target}) ${body} ]);
          default:
            Context.error('Invalid loop iterator', pos);
            macro null;
        }

      case MIf(cond, passing, failed):
        var expr = Context.parse(cond, pos);
        var ifBranch = generateChildren(passing, pos);
        var elseBranch = failed != null 
          ? generateChildren(failed, pos)
          : macro null;
        macro @:pos(pos) if (${expr}) ${ifBranch} else ${elseBranch};

      case MFragment(children):
        var exprs:Array<Expr> = [ for (c in children) generateNode(c) ];
        return macro @:pos(pos) VFragment([ $a{exprs} ]);

      case MNone: null;

    }
  }

  function generateNodeType(name:String, pos:Position):Expr {
    return switch name {
      case 'text': macro @:pos(pos) pilot.TextNodeType;
      default: macro @:pos(pos) pilot.NodeType.get($v{name});
    }
  }

  function generateChildren(children:Array<MarkupNode>, pos:Position):Expr {
    var exprs:Array<Expr> = [ for (child in children) generateNode(child) ];
    return switch exprs.length {
      case 1: exprs[0];
      default: macro @:pos(pos) VFragment([ $a{exprs} ]);
    }
  }

  function generateAttrs(attrs:Array<MarkupAttribute>) {
    var fields:Array<ObjectField> = [];
    for (attr in attrs) { 
      var pos = makePos(attr.value.pos);
      if (attr.name != 'key' && allowKey(attr.name)) {
        if (attr.macroName != null) {
          if (!attributeMacros.exists(attr.macroName)) {
            throw new DslError('Undefined macro @${attr.macroName}', attr.pos);
          }
          fields.push(attributeMacros[attr.macroName](attr, pos));
        } else {
          fields.push({
            field: attr.name,
            expr: switch attr.value.value {
              case Raw(v): macro @:pos(pos) $v{v};
              case Code(v): Context.parse(v, pos);
            }
          });
        }
      }
    }
    return fields;
  }

  function allowKey(key:String) {
    if (Context.defined('js') && !Context.defined('nodejs')) return true;
    return !key.startsWith('on');
  }

  function extractKey(attrs:Array<MarkupAttribute>) {
    for (attr in attrs) if (attr.name == 'key') {
      var pos = makePos(attr.pos);
      return switch attr.value.value {
        case Raw(v): macro @:pos(pos) $v{v};
        case Code(v): Context.parse(v, pos);
      }
    }
    return macro null;
  }

  function makePos(pos:DslPosition):Position {
    return Context.makePosition({
      min: pos.min,
      max: pos.max,
      file: this.pos.getInfos().file
    });
  }

}

#end
