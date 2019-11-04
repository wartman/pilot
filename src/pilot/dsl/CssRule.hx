package pilot.dsl;

enum CssValue {
  Raw(value:String);
  Code(value:String);
}

enum CssSelector {
  CName(s:String);
  CSub(s:String); 
}

enum CssRule {
  CPropety(name:String, value:CssValue);
  CRule(selector:CssSelector, properties:Array<CssRule>);
}
