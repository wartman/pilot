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
  
  @:persistent static var content:Map<String, String> = [];
  static final ucase:EReg = ~/[A-Z]/g;
  static var ran:Array<String> = []; 

  public static function use() {
    if (!Context.defined('display') && !Context.defined('pilot-skip')) {
      Context.onAfterGenerate(() -> write());
    }
  }

  public static function create(expr:Expr, ?className:ExprOf<String>, global:Bool = false) {
    var type = Context.getLocalType().toString();
    var name = className == null ? getId() : switch className.expr {
      case EConst(CString(s)): s;
      case EConst(CIdent('null')): getId();
      default: Context.error('Classname must be a string', className.pos);
    };

    switch expr.expr {
      case EObjectDecl(decls) if (decls.length >= 0):
        add(type, parse('.${name}', decls, global));
      case EBlock(_) | EObjectDecl(_):
        // Empty -- should skip.
      default:
        Context.error('Should be an object', expr.pos);
    }

    return macro $v{name};
  }

  static function add(type:String, value:String) {
    if (ran.indexOf(type) > -1) {
      content.set(type, [ content.get(type), value ].join('\n'));
      return;
    }
    ran.push(type);
    content.set(type, value);
  }

  static function parse(name:String, rules:Array<ObjectField>, global:Bool) {
    var out = [];
    var subStyles = [];
    var type = Context.getLocalType().toString();

    for (rule in rules) switch rule.expr.expr {
      case EConst(CString(s)) | EConst(CInt(s)):
        out.push('${prepareKey(rule.field)}: ${s}');

      case EConst(CIdent(b)):
        var f = Context.getLocalClass().get().findField(b, true);
        if (f == null) {
          Context.error('The field ${b} does not exist', rule.expr.pos);
        }
        if (!f.isFinal) {
          Context.error('Fields used in pilot.Style MUST be final', rule.expr.pos);
        }
        switch f.expr().expr {
          case TConst(TString(s)):
            out.push('${prepareKey(rule.field)}: ${s}');
          case TConst(TInt(s)):
            out.push('${prepareKey(rule.field)}: ${s}');
          default:
            Context.error('Invalid rule', rule.expr.pos);
        }

      case EField(a, b):
        function extract(e:Expr):String {
          return switch e.expr {
            case EField(a, b): 
              extract(a) + '.' + b;
            case EConst(CIdent(s)): 
              s;
            default:
              Context.error('Invalid rule', rule.expr.pos);
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
          Context.error('The type ${typeName} was not found', rule.expr.pos);
        }
        var f = type.findField(b, true);
        if (f == null) {
          Context.error('The field ${typeName}.${b} does not exist', rule.expr.pos);
        }
        if (!f.isFinal) {
          Context.error('Fields used in pilot.Style MUST be final', rule.expr.pos);
        }
        switch f.expr().expr {
          case TConst(TString(s)):
            out.push('${prepareKey(rule.field)}: ${s}');
          case TConst(TInt(s)):
            out.push('${prepareKey(rule.field)}: ${s}');
          default:
            Context.error('Invalid rule', rule.expr.pos);
        }

      case EObjectDecl(decls):
        if (decls.length == 0) continue;
        var selector = parseSelector(name, rule.field, global);
        if (selector.startsWith('@')) {
          subStyles.push('${selector} {\n' + parse(name, decls, global) + '\n}');
        } else {
          subStyles.push(parse(selector, decls, false));
        }

      default:
        Context.error('Invalid rule', rule.expr.pos);
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
