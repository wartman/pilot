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

class StyleBuilder {
  
  @:persistent static var content:Map<String, String> = [];
  static var registered:Bool = false;
  static var prev:String; 

  public static function create(expr:Expr, global:Bool = false) {
    if (!registered && !Context.defined('display')) {
      registered = true;
      prev = null;
      Context.onAfterGenerate(() -> {
        if (!Context.defined('display')) write();
      });
    }

    var type = Context.getLocalType().toString();
    var name = getId();

    switch expr.expr {
      case EBlock(_):
      case EObjectDecl(decls):
        // Hopefully this is all we'll need to ensure multiple
        // `Style`s can be created per type.
        //
        // I want to think of a more elegent method, but this Works
        // for now.
        if (decls.length >= 0) {
          if (prev == type) {
            content.set(type, [
              content.get(type),
              parse('.${name}', decls, global)
            ].join('\n'));
          } else {
            content.set(type, parse('.${name}', decls, global));
          }
        }
      default:
        Context.error('Should be an object', expr.pos);
    }

    // Used to persist multiple styles per type?
    // This seems like a bit of a silly way to do it, but.
    prev = type;
    return macro $v{name};
  }

  static function parse(name:String, rules:Array<ObjectField>, global:Bool) {
    var out = [];
    var subStyles = [];
    for (rule in rules) switch rule.expr.expr {
      case EConst(CString(s)) | EConst(CInt(s)):
        out.push('${rule.field}: ${s}');
      case EObjectDecl(decls):
        if (decls.length == 0) continue;
        var ruleName = global 
          ? rule.field
          : rule.field.indexOf('&') > -1
            ? rule.field.replace('&', name)
            : '${name} ${rule.field}';
        subStyles.push(parse(ruleName, decls, false));
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
    var chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return '_c_' + [ for (i in 0...20) chars.charAt(rand(0, chars.length - 1)) ].join('');
  }

  static function write() {
    var root = Sys.getCwd();
    var outDir = Compiler.getOutput();
    var outName:String = Context.definedValue('pilot-style-name');
    if (outName == null) outName = 'app';
    if (outDir.extension() != '') {
      outDir = outDir.directory();
    }
    outDir = Path.join([outDir, outName]).withExtension('css');
    File.saveContent(outDir, [ for (k => v in content) v ].join('\n'));
  }

}

#end
