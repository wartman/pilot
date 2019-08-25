package pilot.css;

import haxe.macro.Expr;

enum Value {
  VConst(s:String);
  VVariable(e:Expr);
}

enum CssExpr {
  EDeclaration(selectors:Array<String>, properties:Array<CssExpr>);
  EProperty(name:String, value:Value);
}
