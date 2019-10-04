package pilot.macro;

import haxe.macro.Expr;

using Lambda;
using StringTools;

class MetaTools {
  
  public static function getMetaByPrefix(meta:Metadata, prefix:Array<String>) {
    return meta.find(m -> prefix.exists(name -> m.name.startsWith(name)));
  }

  public static function hasMetaByPrefix(meta:Metadata, prefix:Array<String>) {
    return meta.exists(m -> prefix.exists(name -> m.name.startsWith(name)));
  }

}
