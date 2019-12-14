#if macro
package pilot.dsl;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;

using StringTools;
using haxe.macro.PositionTools;
using haxe.io.Path;

class Css {

  static var isInitialized:Bool = false;
  static final isEmbedded:Bool = !Context.defined('pilot-css-output');
  static final isSkipped:Bool = Context.defined('pilot-css-skip');
  
  public static function parse(expr:Expr, forceEmbedding = false, global = false) {
    var info = expr.pos.getInfos();
    var name = getId(expr.pos);
    
    switch expr.expr {
      case EConst(CString(s)):
        try {
          var ast = new CssParser(s, info.file, info.min).parse();
          var css = new CssGenerator(global ? null : name, ast, expr.pos).generate();
          var result = export(name, css, expr.pos, forceEmbedding);
          return if (global) macro null else result; 
        } catch (e:DslError) {
          Context.error(e.message, Context.makePosition({
            min: e.pos.min,
            max: e.pos.max,
            file: info.file
          }));
          return macro null;
        }
      default:
        Context.error('Invalid expression', expr.pos);
        return macro null;
    }
  }

  static function getId(pos:Position) {
    var cls = Context.getLocalClass().get();
    var name = cls.pack.map(part -> part.replace('_', '').substr(0, 1).toLowerCase());
    var clsName = cls.name
      .replace('_', '')
      .toLowerCase()
      .replace('impl', '');
    name.push('_' + clsName.substr(0, 20));
    return name.join('') + pos.getInfos().max;
  }

  static function export(name:String, css:String, pos:Position, forceEmbedding:Bool = false) {
    if (!isInitialized) {
      isInitialized = true;
      if (!isEmbedded && !isSkipped) {
        Context.onGenerate(types -> {
          Context.onAfterGenerate(() -> {
            var out:Array<String> = [];
            
            for (t in types) switch t {
              case TAbstract(_.get() => cls, _) if (cls.meta.has(':pilot_output')):
                for (meta in cls.meta.extract(':pilot_output')) {
                  for (e in meta.params) switch e.expr {
                    case EConst(CString(s)):
                      out.push(s);
                    default:
                      throw 'assert';
                  }
                }
              default:
            }

            sys.io.File.saveContent(switch Context.definedValue('pilot-css-output') {
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

    return createClassName(name, css, pos, forceEmbedding);
  }

  static function createClassName(name:String, css:String, pos:Position, forceEmbedding:Bool) {
    var clsName = 'PilotCss_${name}';
    var cls = 'pilot.styles.${clsName}';
    var abs:TypeDefinition = {
      name: clsName,
      pack: [ 'pilot', 'styles' ],
      kind: TDAbstract(macro:pilot.Style, [], [macro:pilot.Style]),
      meta: [
        {
          name: ':pilot_output',
          params: [  macro $v{css} ],
          pos: Context.currentPos()
        }
      ],
      fields: 
        if ((isEmbedded && !isSkipped) || forceEmbedding)
          (macro class {
            @:keep public static final rules = pilot.StyleManager.define($v{name}, () -> $v{css});
            public inline function new() this = new pilot.Style($v{name});
          }).fields
        else 
          (macro class {
            public inline function new() this = new pilot.Style($v{name});
          }).fields,
      pos: Context.currentPos()
    };
    Context.defineType(abs);
    return macro new pilot.styles.$clsName();
  }

}

#end