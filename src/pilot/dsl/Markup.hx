#if macro
package pilot.dsl;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.PositionTools;

class Markup {

  static final defaultFactory = createFactory([
    'style' => (attr, pos) -> {
      field: attr.name,
      expr: switch attr.value.value {
        case Raw(_):
          throw new DslError('@style does not accept raw values', attr.pos);
        case Code(value):
          Css.parse(macro @:pos(pos) $v{value});
      }
    },
    'style-embed' => (attr, pos) -> {
      field: attr.name,
      expr: switch attr.value.value {
        case Raw(_):
          throw new DslError('@style-embed does not accept raw values', attr.pos);
        case Code(value):
          Css.parse(macro @:pos(pos) $v{value}, true);
      }
    }
  ], {
    noInlineControlFlow: Context.defined('pilot-markup-no-inline-control-flow')
  });

  /**
    Parse an expression using the default markup parser.
  **/
  public static function parse(expr:Expr) {
    return defaultFactory.create(expr);
  }

  /**
    Use this method to create custom markup parsers.
  **/
  public static function createFactory(macros, options) {
    return new MarkupFactory(macros, options);
  }

}
#end
