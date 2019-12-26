package pilot.dsl;

typedef MarkupAttribute = { 
  name:String,
  value:{
    value:MarkupAttributeValue,
    pos:DslPosition
  },
  ?macroName:String,
  pos:DslPosition
}

enum MarkupAttributeValue {
  Raw(value:String);
  Code(value:String);
}

enum MarkupNodeDef {
  MNode(
    name:String,
    attrs:Array<MarkupAttribute>,
    children:Array<MarkupNode>,
    isComponent:Bool
  );
  MFragment(children:Array<MarkupNode>);
  MText(value:String);
  MCode(value:String);
  // MIf(
  //   cond:String,
  //   passing:Array<MarkupNode>,
  //   ?failed:Array<MarkupNode>
  // );
  // MFor(
  //   it:String,
  //   children:Array<MarkupNode>,
  //   ?failed:Array<MarkupNode>
  // );
  // MSwitch(
  //   target:String,
  //   cases:Array<{
  //     cond:String,
  //     children:Array<MarkupNode>
  //   }>
  // );
  MNone;
}

typedef MarkupNode = {
  node:MarkupNodeDef,
  pos:DslPosition
}
