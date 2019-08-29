#if macro

package pilot.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.ds.Map;
import sys.io.File;

using StringTools;
using haxe.io.Path;
using haxe.macro.Tools;
using haxe.macro.TypeTools;

class StyleBuilder {
  
  @:persistent static public var content:Map<String, String> = [];
  static final ucase:EReg = ~/[A-Z]/g;
  static var ran:Array<String> = []; 

  public static function use() {
    if (
      Context.defined('pilot-css')
      && !Context.defined('display') 
      && !Context.defined('pilot-skip')
    ) {
      Context.onAfterGenerate(() -> write());
    }
  }

  public static function create(expr:Expr, ?className:ExprOf<String>, global:Bool = false) {
    var type = Context.getLocalType().toString();
    var id = getId();
    var name = className == null ? id : switch className.expr {
      case EConst(CString(s)): s;
      case EConst(CIdent('null')): id;
      default: Context.error('Classname must be a string', className.pos);
    };

    var rules = switch expr.expr {
      case EObjectDecl(decls) if (decls.length >= 0):
        add(type, parse('.${name}', decls, global));
      case EBlock(_) | EObjectDecl(_):
        // Empty -- should skip.
        '';
      default:
        Context.error('Should be an object', expr.pos);
        '';
    }

    if (!Context.defined('pilot-css') && !Context.defined('pilot-skip')) {
      var clsName = id.replace('-', '_').toUpperCase();
      var cls = 'pilot.styles.${clsName}';
      var abs:TypeDefinition = {
        name: clsName,
        pack: [ 'pilot', 'styles' ],
        kind: TDAbstract(macro:String, [], [macro:String]),
        fields: (macro class {
          @:keep public static final rules = pilot.StyleManager.define($v{name}, () -> $v{rules});
          public inline function new() this = $v{name};
        }).fields,
        pos: Context.currentPos()
      };
      Context.defineType(abs);
      return macro new pilot.styles.$clsName();
    } else {
      return macro $v{name};
    }
  }

  static function add(type:String, value:String):String {
    if (ran.indexOf(type) > -1) {
      content.set(type, [ content.get(type), value ].join('\n'));
      return value;
    }
    ran.push(type);
    content.set(type, value);
    return value;
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
    function rand(from:Int, to:Int):Int {
      return from + Math.floor((to - from) * Math.random());
    }
    var prefix = Context.defined('pilot-prefix') ? Context.definedValue('pilot-prefix') : '_';
    var chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return prefix + [ for (i in 0...5) chars.charAt(rand(0, chars.length - 1)) ].join('');
  }

  static function write() {
    var root = Sys.getCwd();
    var outDir = Compiler.getOutput();
    var outName:String = Context.definedValue('pilot-css');
    if (outName == null) outName = 'app';
    if (outDir.extension() != '') {
      outDir = outDir.directory();
    }
    outDir = Path.join([outDir, outName.trim()]).withExtension('css');
    File.saveContent(outDir, [ for (k => v in content) v ].join('\n'));
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

}

#end
