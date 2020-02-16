#if macro
package pilot.dsl;

import haxe.macro.Context;
import haxe.macro.Expr;
import pilot.dsl.MarkupNode;

using StringTools;
using haxe.macro.PositionTools;

typedef MarkupMacro = (attr:MarkupAttribute, pos:Position)->ObjectField;

class MarkupGenerator {

  static inline final TEXT_NODE = '__text__';
  
  final attributeMacros:Map<String, MarkupMacro>;
  final nodes:Array<MarkupNode>;
  final pos:Position;
  var isSvg:Bool = false;

  public function new(nodes, pos, macros) {
    this.nodes = nodes;
    this.pos = pos;
    this.attributeMacros = macros;
  }

  public function generate():Expr {
    var exprs:Array<Expr> = [ 
      for (node in nodes) generateNode(node) 
    ].filter(e -> e != null);
    var eType = exprs.length == 1 
      ? exprs[0] 
      : macro VFragment([ $a{exprs} ]);

    return macro @:pos(pos) (${eType}:pilot.VNode);
  }

  function generateNode(node:MarkupNode):Expr {
    if (node == null) return null;
    var pos = makePos(node.pos);
    return switch node.node {

      case MNode(name, attrs, children, false):
        // Trying to handle SVG this way, not sure if it's
        // wise though.
        var svgBefore = isSvg;
        if (name == 'svg') isSvg = true;

        var ref = extractAttribute('@ref', attrs);
        var key = extractAttribute('@key', attrs);
        var dangerouslySetInnerHTML = extractAttribute('@dangerouslySetInnerHTML', attrs);
        var fields = generateAttrs(attrs);
        var type = generateNodeType(name, pos);

        var attrs:Expr = {
          expr: EObjectDecl(fields),
          pos: pos
        };
        var children:Array<Expr> = children == null ? [] : [ for (c in children)
          generateNode(c)
        ].filter(e -> e != null);

        isSvg = svgBefore;
        
        macro @:pos(pos) VNative(
          ${type}, 
          ${attrs}, 
          [ $a{children} ],
          ${key},
          ${dangerouslySetInnerHTML},
          ${ref}
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
        
        var key = extractAttribute('@key', attrs);
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

        if (Context.unify(type, Context.getType('pilot.VNode'))) {
          macro @:pos(pos) new $tp($attrs);
        } else {
          if (!Context.unify(type, Context.getType('pilot.Component'))) {
            Context.error('Components must implement pilot.Component', pos);
          }
          macro @:pos(pos) VComponent(
            $p{tp.pack.concat([ tp.name ])},
            ${attrs},
            ${key}
          );
        }

      case MCode(v):
        var e = parseExpr(v, pos);
        macro @:pos(pos) (${e}:pilot.VNodeValue);

      case MText(value):
        macro @:pos(pos) VNative(${generateNodeType(TEXT_NODE, pos)}, $v{value}, []);

      case MFragment(children):
        var exprs:Array<Expr> = [ for (c in children) generateNode(c) ];
        macro @:pos(pos) VFragment([ $a{exprs} ]);

      case MNone: null;

    }
  }

  function generateNodeType(name:String, pos:Position):Expr {
    return switch name {
      case TEXT_NODE: macro @:pos(pos) pilot.TextType;
      case _ if (isSvg): macro @:pos(pos) pilot.NodeType.getSvg($v{name});
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
      if (allowKey(attr.name)) {
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
              case Code(v): parseExpr(v, pos);
            }
          });
        }
      }
    }
    return fields;
  }

  function allowKey(key:String) {
    if (key.startsWith('@')) return false;
    return true;
  }

  function extractAttribute(name:String, attrs:Array<MarkupAttribute>) {
    for (attr in attrs) if (attr.name == name) {
      var pos = makePos(attr.pos);
      return switch attr.value.value {
        case Raw(v): macro @:pos(pos) $v{v};
        case Code(v): parseExpr(v, pos);
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

  function parseExpr(src:String, pos) {
    var e = try Context.parseInlineString(src, pos)
      catch (e:haxe.macro.Error) throw e
      catch (e:Dynamic) Context.error(e, pos);
    switch e.expr {
      case EMeta({ name : ":markup" }, { expr : EConst(CString(value)), pos : pos }):
        e = Markup.parse(macro @:pos(pos) $v{value});
      default:
        reenterLoop(e);
    }
    return e;
  }

  function reenterLoop(e:Expr) {
    switch e {
      case macro @:markup $value:
        e.expr = Markup.parse(value).expr;
      default:
        haxe.macro.ExprTools.iter(e, e -> reenterLoop(e));
    }
  }

}

#end
