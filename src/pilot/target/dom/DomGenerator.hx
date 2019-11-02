#if macro

package pilot.target.dom;

import haxe.macro.Expr;
import pilot.dsl.MarkupGenerator;

class DomGenerator extends MarkupGenerator {
  
  override function generateNodeType(name:String, pos:Position):Expr {
    return switch name {
      case 'text': macro @:pos(pos) pilot.target.dom.DomTextNodeType.inst;
      default: macro @:pos(pos) pilot.target.dom.DomNodeType.get($v{name});
    }
  }

}

#end
