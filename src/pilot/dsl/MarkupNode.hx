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
  MNone;
}

typedef MarkupNode = {
  node:MarkupNodeDef,
  pos:DslPosition
}
