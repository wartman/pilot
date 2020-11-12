package pilot.builder;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;

using Lambda;

enum FieldBuilderHook {
  Init;
  Normal;
  After;
}

typedef BuilderOption = {
  name:String,
  optional:Bool,
  ?handleValue:(expr:Expr)->Expr
} 

typedef FieldMetaBuilder<Options:{}> = {
  public var name:String;
  public var multiple:Bool;
  public var similarNames:Array<String>;
  public var hook:FieldBuilderHook;
  public var options:Array<BuilderOption>;
  public function build(options:Options, builder:ClassBuilder, f:Field):Void;
}

typedef ClassMetaBuilder<Options:{}> = {
  public var name:String;
  public var multiple:Bool;
  public var required:Bool;
  public var similarNames:Array<String>;
  public var options:Array<BuilderOption>;
  public function build(options:Options, builder:ClassBuilder, fields:Array<Field>):Void;
} 

class ClassBuilder {
  
  var fields:Array<Field>;
  final cls:ClassType;
  final classBuilders:Array<ClassMetaBuilder<Dynamic>> = []; 
  final fieldBuilders:Array<FieldMetaBuilder<Dynamic>> = [];

  public function new(fields, cls) {
    this.fields = fields;
    this.cls = cls;
  }

  public function addClassBuilder<Options:{}>(builder:ClassMetaBuilder<Options>) {
    classBuilders.push(builder);
  }

  public function addFieldBuilder<Options:{}>(builder:FieldMetaBuilder<Options>) {
    fieldBuilders.push(cast builder);
  }

  public function run() {
    checkMeta();

    parseClassMeta();

    function parseFieldMetaHook(hook:FieldBuilderHook) {
      var copy = fields.copy();
      var fb = fieldBuilders.filter(h -> h.hook == hook);
      if (fb.length > 0) for (f in copy) parseFieldMeta(f, fb);
    }
    
    parseFieldMetaHook(Init);
    parseFieldMetaHook(Normal);
    parseFieldMetaHook(After);
  }

  function parseClassMeta() {
    for (builder in classBuilders) {
      if (cls.meta != null && cls.meta.has(builder.name)) {
        function handle(meta:MetadataEntry) {
          var options = parseOptions(meta.params, builder.options, meta.pos);
          builder.build(options, this, fields.copy());
        }
        
        switch cls.meta.extract(builder.name) {
          case [ m ]: handle(m);
          case many: 
            if (builder.multiple) {
              for (m in many) handle(m);
            } else {
              Context.error('Only one @${builder.name} is allowed', many[1].pos);
            }
        }

      } else if (builder.required) {
        Context.error('The class meta @${builder.name} is required', cls.pos);
      }
    }
  }

  function parseFieldMeta(field:Field, fieldBuilders:Array<FieldMetaBuilder<Dynamic>>) {
    for (builder in fieldBuilders) {
      var match = (m:MetadataEntry) -> m.name == builder.name; 
      if (field.meta != null && field.meta.exists(match)) {
        function handle(meta:MetadataEntry) {
          var options = parseOptions(meta.params, builder.options, meta.pos);
          builder.build(options, this, field);
        }

        switch field.meta.filter(match) {
          case [ m ]: handle(m);
          case many: 
            if (builder.multiple) {
              for (m in many) handle(m);
            } else {
              Context.error('Only one @${builder.name} is allowed', many[1].pos);
            }
        }

      }
    }
  }

  function parseOptions(
    params:Array<Expr>,
    def:Array<BuilderOption>,
    pos:Position
  ):{} {
    var options:{} = {};

    function addOption(name:String, value:Expr, pos:Position) {
      var info = def.find(o -> o.name == name);
      if (info == null) {
        Context.error('The option [ ${name} ] is not allowed here', pos);
      }
      if (Reflect.hasField(options, name)) {
        Context.error('The option ${name} was defined twice', pos);
      }
      Reflect.setField(options, name, info.handleValue != null
        ? info.handleValue(value)
        : parseConst(value)
      );
    }

    for (p in params) switch p {
      case macro ${ { expr:EConst(CIdent(s)), pos: _ } } = ${e}:
        addOption(s, e, p.pos);
      case macro ${ { expr:EConst(CIdent(s)), pos: _ } }:
        addOption(s, macro true, p.pos);
      default:
        Context.error('Invalid expression', p.pos);
    }

    for (o in def) {
      if (!Reflect.hasField(options, o.name)) {
        if (!o.optional) {
          Context.error('Missing required option ${o.name}', pos);
        }
      }
    }

    return options;
  }

  function checkMeta() {
    var allowedMeta = [ for (b in fieldBuilders) b.name ];
    
    for (f in fields) {
      var meta = f.meta;
      if (meta != null) for (m in meta) {
        for (b in fieldBuilders) {
          if (b.similarNames.has(m.name)) {
            Context.error(
              'Unexpected @${m.name}. Did you mean @${b.name}? '
              + '(tip: this is probably a typo)',
              m.pos
            );
          }
        }
      }
    }
  }

  public function add(fields:Array<Field>) {
    this.fields = this.fields.concat(fields);
  }

  public function export() {
    return fields;
  }

  function parseConst(expr:Expr):Dynamic {
    return switch expr.expr {
      case EConst(c): switch c {
        case CIdent('false'): false;
        case CIdent('true'): true;
        case CString(s, _) | CIdent(s): s;
        case CInt(v): v;
        case CFloat(f): f;
        case CRegexp(_, _):
          Context.error('Regular expressions are not allowed here', expr.pos);
          null;
      }
      default: 
        Context.error('Values must be constant', expr.pos);
        null;
    }
  }

}
