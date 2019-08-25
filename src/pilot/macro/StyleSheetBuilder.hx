#if macro

package pilot.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import pilot.css.*;

using Lambda;

class StyleSheetBuilder {

  public static final styleMeta = [ ':style' ];
  
  public static function build() {
    var fields = Context.getBuildFields();
    var cls = Context.getLocalClass().get();
    var clsName = cls.pack.concat([ cls.name ]).join('_').toLowerCase();
    
    for (f in fields) switch f.kind {
      case FVar(t, e) if (f.meta.exists(m -> styleMeta.has(m.name))):
        if (!f.access.has(AStatic)) {
          Context.error('All style fields in StyleSheets must be static', f.pos);
        }
        if (!f.access.has(APublic)) {
          f.access.push(APublic);
        }
        createStyle(clsName, f, t, e);
      default:
    }

    return fields;
  }

  public static function createStyle(clsName:String, f:Field, t:ComplexType, e:Expr) {
    if (e == null) Context.error('An expression is required', f.pos);
    var name = '${clsName}_${f.name.toLowerCase()}';
    var css = Generator.generate('.$name', Parser.parse(e));
    f.kind = FVar(macro:pilot.Style, macro pilot.StyleManager.define($v{name}, () -> ${css}));
  }

}

#end

