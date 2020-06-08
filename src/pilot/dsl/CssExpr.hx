package pilot.dsl;

typedef CssExpr = {
  expr:CssExprDef,
  pos:DslPosition
}

enum abstract UnOp(String) from String to String {
  var UnOpSubt = '-';

  public static final all:Array<String> = [ UnOpSubt ];
}

enum abstract BinOp(String) from String to String {
  var OpAdd = '+';
  var OpSubt = '-';
  var OpMult = '*';
  var OpDiv = '/';

  public static final all:Array<String> = [ OpAdd, OpSubt, OpMult, OpDiv ];
}

enum abstract Unit(String) to String from String {
  var None = null;
  var Px = 'px';
  var Pct = '%';
  var Em = 'em';
  var Rem = 'rem';
  var VH = 'vh';
  var VW = 'vw';
  var VMin = 'vmin';
  var VMax = 'vmax';
  var Deg = 'deg';
  var Sec = 's';
  var MS = 'ms';
  var Fr = 'fr';

  public static final all = [ Px, Pct, Em, Rem, VH, VW, VMin, VMax, Deg, Sec, MS, Fr ];
}

enum ValueDef {
  VCode(code:String);
  VNumeric(data:String, unit:Unit);
  VAtom(data:String);
  VString(data:String);
  VColor(data:String);
  VCall(name:String, args:Array<Value>);
  VUnOp(op:UnOp, right:Value);
  VBinOp(op:BinOp, left:Value, right:Value);
  VCompound(values:Array<Value>);
  VList(left:Value, right:Value);
}

typedef Value = {
  value:ValueDef,
  pos:DslPosition
}

enum CssExprDef {
  CNone;
  CGlobal(decls:Array<CssExpr>);
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
