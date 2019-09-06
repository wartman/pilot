#if macro

package pilot.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.ds.Map;
import sys.io.File;

using StringTools;
using haxe.macro.Tools;
using haxe.macro.TypeTools;
using haxe.io.Path;

class StyleBuilder {
  
  @:persistent static var id:Int = 0;
  static final prefix = Context.defined('pilot-prefix') 
    ? Context.definedValue('pilot-prefix').replace('-', '_')
    : 'pilot_';
  static final ucase:EReg = ~/[A-Z]/g;
  static var ran:Array<String> = [];
  static var isInitialized:Bool = false;
  static final isEmbedded:Bool = !Context.defined('pilot-css');
  static final isSkipped:Bool = Context.defined('pilot-skip');

  public static function create(expr:Expr, global:Bool = false) {
    // var id = getId();
    // var rules = [ parseSingle(id, expr, global) ];
    // var inst = export(id, rules);
    // return macro ${inst}.$id;
    return createNamed(getId(), expr, global);
  }

  public static function createNamed(id:String, expr:Expr, global:Bool = false) {
    var rules = [ parseSingle(id, expr, global) ];
    var inst = export(id, rules);
    return macro ${inst}.$id;
  }

  public static function createSheet(expr:Expr, global:Bool = false) {
    var rules = parseSheet(expr, global);
    return export(getId(), rules);
  }

  static function parseSingle(name:String, expr:Expr, global:Bool):CssRule {
    var css = switch expr.expr {
      case EObjectDecl(decls) if (decls.length >= 0):
        parse('.${name}', decls, global);
      case EObjectDecl(_) | EBlock(_):
        // Skip empty objects.
        '';
      default:
        Context.error('Only an object is accepted here', expr.pos);
        '';
    }
    return {
      name: name,
      css: css,
      pos: expr.pos
    };
  }

  static function parseSheet(expr:Expr, global:Bool):Array<CssRule> {
    return switch expr.expr {
      case EObjectDecl(decls):
        [ for (d in decls) parseSingle(d.field, d.expr, global) ];
      default:
        Context.error('Only an object is accepted here', expr.pos);
        [];
    }
  }

  static function parse(name:String, rules:Array<ObjectField>, global:Bool) {
    var out = [];
    var subStyles = [];
    var type = Context.getLocalType().toString();

    for (rule in rules) switch rule.field {
      case 'media': 
        subStyles.push(parseMedia(name, rule.expr, global));

      // case 'extend':

      // case 'import':

      default: switch rule.expr.expr {
        case EObjectDecl(decls):
          if (decls.length == 0) continue;
          var selector = parseSelector(name, rule.field, global);
          if (selector.startsWith('@')) {
            subStyles.push('${selector} {\n' + parse(name, decls, global) + '\n}');
          } else {
            subStyles.push(parse(selector, decls, false));
          }

        case EBinop(OpAdd, e1, e2):
          for (e in [e1, e2]) out.push(parseRule(name, rule.field, e, global));

        default:
          out.push(parseRule(name, rule.field, rule.expr, global));
      }
    }
    
    if (out.length == 0) {
      return subStyles.length > 0 
        ? subStyles.join('\n')
        : '';
    }

    if (global) {
      return [
        out.map(s -> '  ' + s + ';').join('\n')
      ].concat(subStyles).join('\n');
    }

    return [
      '${name} {',
      out.map(s -> '  ' + s + ';').join('\n'),
      '}'
    ].concat(subStyles).join('\n');
  }

  // this is a work in progress
  static function parseMedia(name:String, expr:Expr, global:Bool = false) {
    var mediaQuery:String = null;
    var mediaBody:String = null;

    function parseMediaQuery(expr:Expr) return switch expr.expr {
      case EBinop(OpAdd | OpAnd | OpBoolAnd, e1, e2):
        [ for (d in [ e1, e2 ]) parseMediaQuery(d) ].join(' and ');

      case EBinop(OpOr | OpBoolOr, e1, e2):
        [ for (d in [ e1, e2 ]) parseMediaQuery(d) ].join(' or ');

      case EObjectDecl(fields): 
        var q = [ for (f in fields) switch f.field {
          case 'type': switch f.expr.expr {
            case EConst(CString(s)): s;
            default: Context.error('Invalid media type', f.expr.pos);
          }
          case 'and': 'and ' + parseMediaQuery(f.expr);
          case 'or': 'or ' + parseMediaQuery(f.expr); 
          default: '(${parseRule(name, f.field, f.expr, global)})';
        } ];
        var isJoin = (s:String) -> s.startsWith('and') || s.startsWith('or'); 
        q.sort((a, b) -> {
          return if (isJoin(a) && !isJoin(b)) 1;
          else if (!isJoin(a) && isJoin(b)) -1;
          else 0;
        });
        q.join(' ');
        
      default: Context.error('Invalid media query', expr.pos);
    }

    function parseMediaScopedRules(expr:Expr) return switch expr.expr {
      case EObjectDecl(fields): parse(name, fields, global);
      case EBinop(OpAdd, e1, e2): 
        [ for (d in [ e1, e2 ]) parseMediaScopedRules(expr) ].join('\n');
      default: Context.error('Invalid media rules', expr.pos);
    }

    switch expr.expr {
      case EBinop(OpAdd, e1, e2):
        return [ 
          parseMedia(name, e1, global),
          parseMedia(name, e2, global) 
        ].join('\n');

      case EObjectDecl(fields): for (f in fields) switch f.field {
        case 'query': mediaQuery = parseMediaQuery(f.expr);
        case 'style': mediaBody = parseMediaScopedRules(f.expr);
        case s: Context.error('${s} is not a valid `media` rule', expr.pos);
      }

      default: Context.error('Invalid media rule', expr.pos);
    }

    return [
      '@media ',
      mediaQuery,
      '{\n',
      mediaBody,
      '\n}'
    ].filter(m -> m != null).join('');
  }

  static function parseRule(name:String, field:String, expr:Expr, global:Bool):String {
    return switch expr.expr {
      case EConst(CString(s)) | EConst(CInt(s)):
        '${prepareKey(field)}: ${s}';

      case EConst(CIdent(b)):
        var f = Context.getLocalClass().get().findField(b, true);
        if (f == null) {
          Context.error('The field ${b} does not exist', expr.pos);
        }
        if (!f.isFinal) {
          Context.error('Fields used in pilot.Style MUST be final', expr.pos);
        }
        switch f.expr().expr {
          case TConst(TString(s)):
            '${prepareKey(field)}: ${s}';
          case TConst(TInt(s)):
            '${prepareKey(field)}: ${s}';
          default:
            Context.error('Invalid rule', expr.pos);
            '';
        }

      case EField(a, b):
        function extract(e:Expr):String {
          return switch e.expr {
            case EField(a, b): 
              extract(a) + '.' + b;
            case EConst(CIdent(s)): 
              s;
            default:
              Context.error('Invalid rule', expr.pos);
              null;
          }
        }
        var typeName = extract(a);
        if (typeName.indexOf('.') < 0) {
          typeName = getTypePath(typeName, Context.getLocalImports());
        }
        var type = try {
          Context.getType(typeName).getClass();
        } catch (e:String) {
          Context.error('The type ${typeName} was not found', expr.pos);
        }
        var f = type.findField(b, true);
        if (f == null) {
          Context.error('The field ${typeName}.${b} does not exist', expr.pos);
        }
        if (!f.isFinal) {
          Context.error('Fields used in pilot.Style MUST be final', expr.pos);
        }
        switch f.expr().expr {
          case TConst(TString(s)):
            '${prepareKey(field)}: ${s}';
          case TConst(TInt(s)):
            '${prepareKey(field)}: ${s}';
          default:
            Context.error('Invalid rule', expr.pos);
            '';
        }

      default:
        Context.error('Invalid rule', expr.pos);
    }
    
  }

  static function getId() {
    return prefix + id++;
  }

  static function prepareKey(key:String) {
    return [ for (i in 0...key.length)
      if (ucase.match(key.charAt(i))) {
        '-' + key.charAt(i).toLowerCase();
      } else {
        key.charAt(i);
      } 
    ].join('');
  }

  static function getTypePath(name:String, imports:Array<ImportExpr>):String {
    // check imports
    for (i in imports) switch i.mode {
      case IAsName(n):
        if (n == name) {
          var name = i.path[i.path.length - 1].name; 
          var pack = [ for (index in 0...i.path.length-1) i.path[index].name ];
          return pack.concat([ name ]).join('.');
        }
      default:
        var n = i.path[i.path.length - 1].name;
        if (n == name) {
          var pack = [ for (index in 0...i.path.length-1) i.path[index].name ];
          return pack.concat([ name ]).join('.');
        }
    }

    // If not found, assume local or full type path.
    return name;
  }

  static function parseSelector(parent:String, selector:String, isGlobal:Bool) {
    if (selector.contains('@')) {
      return selector.trim();
    }

    if (!isGlobal) {
      if (selector.contains('&')) {
        selector = selector.replace('&', parent);
      } else {
        selector = '${parent} ${selector}';
      }
    }

    return selector;
  }
  
  static function export(id:String, rules:Array<CssRule>) {
    if (!isInitialized) {
      isInitialized = true;
      if (!isEmbedded && !isSkipped) {
        Context.onGenerate(types -> {
          Context.onAfterGenerate(() -> {
            var out:Array<String> = [];
            
            for (t in types) switch t {
              case TInst(_.get() => cls, _) if (cls.meta.has(':pilot_output')):
                for (field in cls.fields.get()) {
                  for (meta in field.meta.extract(':pilot_output')) {
                    for (e in meta.params) switch e.expr {
                      case EConst(CString(s)):
                        out.push(s);
                      default:
                        throw 'assert';
                    }
                  }
                }
              default:
            }

            sys.io.File.saveContent(switch Context.definedValue('pilot-css') {
              case abs = _.charAt(0) => '.' | '/': abs;
              case relative:
                Path.join([
                  sys.FileSystem.absolutePath(Compiler.getOutput().directory()),
                  relative
                ]);
            }, out.join('\n'));
          });
        });
      }
    }

    return createRulesClass(id, rules);
  }

  static function createRulesClass(id:String, rules:Array<CssRule>) {
    var clsName = ('Pilot_Css_' + id).replace('-', '_');
    var tp = { pack: [], name: clsName };
    var ruleGen = if (rules.length > 1) {
      var ruleList:Array<Expr> = [ for (rule in rules) {
        var name = rule.name;
        macro this.$name;
      } ];
      macro pilot.Style.compose([ $a{ruleList} ]);
    } else {
      var name = rules[0].name;
      macro this.$name;
    }
    var cls = macro class $clsName implements pilot.StyleSheet {
      public static final inst = new $tp();
      public function new() {}
      public inline function all() {
        return ${ruleGen};
      }
    }

    cls.meta.push({
      name: ':pilot_output',
      params: [],
      pos: cls.pos
    });

    for (rule in rules) {
      cls.fields.push({
        name: rule.name,
        pos: rule.pos,
        access: [ APublic, AFinal ],
        kind: FVar(
          macro:pilot.Style,
          if (isEmbedded && !isSkipped)
            macro new pilot.Style(pilot.StyleManager.define($v{rule.name}, () -> $v{rule.css}));
          else
            macro new pilot.Style($v{rule.name})
        ),
        meta: [
          {
            name: ':pilot_output',
            params: [ macro $v{rule.css} ],
            pos: rule.pos
          }
        ]
      });
    }

    Context.defineType(cls);

    return macro $i{clsName}.inst;
  }

}

private typedef CssRule = {
  name:String,
  css:String,
  pos:Position
}

#end
