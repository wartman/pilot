#if macro
package pilot.target.sys;

import haxe.macro.Expr;
import pilot.dsl.MarkupGenerator;

using StringTools;

class SysGenerator extends MarkupGenerator {
  
  override function generateNodeType(name:String, pos:Position):Expr {
    return switch name {
      case 'text': macro @:pos(pos) pilot.target.sys.SysTextNodeType.inst;
      default: macro @:pos(pos) pilot.target.sys.SysNodeType.get($v{name});
    }
  }

  override function allowKey(key:String):Bool {
    return !key.startsWith('on');
  }

}

#end