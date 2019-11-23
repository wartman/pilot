package pilot.dsl;

typedef CssExpr = {
  expr:CssExprDef,
  pos:DslPosition
}

enum CssExprDef {
  CDeclaration(selector:Selector, properties:Array<CssExpr>);
  CMediaQuery(conditions:Array<MediaCondition>, properties:Array<CssExpr>);
  CKeyframes(name:String, properties:Array<CssExpr>);
  CFontFace(properties:Array<CssExpr>);
  CPropety(name:String, value:Value);
}

enum abstract MediaType(String) to String {
  var All = 'all';
  var Print = 'print';
  var Screen = 'screen';
  var Speech = 'speech';
}

enum MediaCondition {
  And(a:MediaCondition, b:MediaCondition);
  Negated(cond:MediaCondition);
  Feature(name:String, value:Value);
  Type(type:MediaType);
}

enum ValueDef {
  Raw(value:String);
  Code(value:String);
}

typedef Value = {
  value:ValueDef,
  pos:DslPosition
}

typedef Selector = {
  selector: Array<SelectorOption>,
  pos:DslPosition
};

typedef SelectorOption = Array<SelectorPart>;

typedef SelectorPart = {
  ?placeholder:Bool,
  ?id:String,
  ?tag:String,
  ?classes:Array<String>,
  ?attrs:Array<AttrSelector>,
  ?pseudos:Array<Pseudo>,
  ?combinator:Combinator
}

typedef AttrSelector = {
  name:String,
  ?value:String,
  ?op:AttrOperator
}

enum abstract AttrOperator(String) to String {
  var None = '';
  var WhitespaceSeperated = '~=';
  var HyphenSeparated = '|=';
  var BeginsWith = '^=';
  var EndsWith = '$=';
  var Contains = '*=';
  var Exactly = '=';
}

enum abstract Combinator(String) to String {
  var Descendant = null;
  var Child = '>';
  var AdjacentSibling = '+';
  var GeneralSibling = '~';
}

enum abstract Directionality(String) to String {
  var Rtl = 'rtl';
  var Ltr = 'ltr';
}

enum Pseudo {
  Vendored(s:String);
  Active;
  AnyLink;
  Blank;
  Checked;
  Current;
  Default;
  Defined;
  Dir(d:Directionality);
  Disabled;
  Drop;
  Empty;
  Enabled;
  FirstChild;
  FirstOfType;
  Fullscreen;
  Future;
  Focus;
  FocusVisible;
  FocusWithin;
  Hover;
  Indeterminate;
  InRange;
  Invalid;
  Lang(lang:String);
  LastChild;
  LastOfType;
  Link;
  LocalLink;
  NthChild(factor:Int, offset:Int);
  NthLastChild(factor:Int, offset:Int);
  NthLastOfType(factor:Int, offset:Int);
  NthOfType(factor:Int, offset:Int);
  OnlyChild;
  OnlyOfType;
  Optional;
  OutOfRange;
  Past;
  PlaceholderShown;
  ReadOnly;
  ReadWrite;
  Required;
  Right;
  Root;
  Scope;
  Target;
  TargetWithin;
  UserInvalid;
  Valid;
  Visited;
  GrammarError;
  Marker;
  Placeholder;
  Selection;
  SpellingError;
  After;
  Before;
  Cue;
  FirstLetter;
  FirstLine;
  Has(s:Selector);
  Is(s:Selector);
  Not(s:Selector);
  Where(s:Selector);
}
