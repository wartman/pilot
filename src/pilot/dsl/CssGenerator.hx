#if macro
package pilot.dsl;

import haxe.macro.Context;
import haxe.macro.Expr;
import pilot.dsl.CssExpr;

using StringTools;
using haxe.macro.PositionTools;
using haxe.macro.TypeTools;

class CssGenerator {
  
  final root:String;
  final rules:Array<CssExpr>;
  final pos:Position;
  var indentSize:Int = 0;
  var decls:Array<String> = [];

  public function new(root, rules, pos) {
    this.root = root;
    this.rules = rules;
    this.pos = pos;
  }

  public function generate():String {
    return generateDeclaration({
      selector: [ 
        if (root != null) [{ classes: [ root ] }]
        else [ {} ] 
      ],
      pos: {
        min: pos.getInfos().min,
        max: pos.getInfos().min + (root != null ? root.length : 1)
      }
    }, rules);
  }

  function generateDeclaration(selector:Selector, properties:Array<CssExpr>, ?parent:String):String {
    var decls:Array<String> = [];
    var props:Array<String> = [];
    var sel = generateSelector(selector, parent);

    for (prop in properties) if (prop != null) switch prop.expr {
      case CNone:
        // noop
      case CDeclaration(selector, properties):
        var decl = generateDeclaration(selector, properties, sel);
        if (decl != null) decls.push(decl);
      case CPropety(name, value):
        props.push(generateProperty(name, value));
      case CMediaQuery(conditions, properties):
        var decl = generateMediaQuery(conditions, properties, sel);
        if (decl != null) decls.push(decl);
      case CKeyframes(name, properties):
        var decl = generateKeyframes(name, properties);
        if (decl != null) decls.push(decl);
      case CGlobal(props):
        decls.push(generateDeclaration({
          selector: [ [{}] ],
          pos: prop.pos
        }, props));
      case CFontFace(properties):
        decls.push(generateFontFace(properties));
      default:
        throw new DslError('Not implented yet', prop.pos);
    }

    if (props.length > 0) {
      indent();
      var p = props.map(p -> '${getIndent()}$p').join('\n');
      outdent();
      var decl = '${getIndent()}${sel} {\n${p}\n${getIndent()}}';
      decls.unshift(decl);
    }

    return decls.length > 0 ? decls.join('\n') : null;
  }

  function generateProperty(name:String, value:Value):String {
    return '${name}: ${generateValue(value)};';
  }

  function generateValue(value:Value):String {
    return switch value.value {
      case VAtom(value): value;
      case VUnOp(op, right):
        return '${op}${generateValue(right)}';
      case VBinOp(op, left, right):
        return '${generateValue(left)} ${op} ${generateValue(right)}';
      case VCode(v):
        var expr = Context.parse(v, Context.makePosition({
          min: value.pos.min,
          max: value.pos.max,
          file: pos.getInfos().file
        }));
        
        return switch expr.expr {
          case EConst(CString(s, _)): s;
          case EConst(CInt(s)): Std.string(s);
          case EField(a, b): // todo: pull this out?
            function extract(e:Expr):String {
              return switch e.expr {
                case EField(a, b): 
                  extract(a) + '.' + b;
                case EConst(CIdent(s)): 
                  s;
                default:
                  Context.error('Invalid rule', expr.pos);
                  null;
              }
            }
            var typeName = extract(a);
            if (typeName.indexOf('.') < 0) {
              typeName = getTypePath(typeName, Context.getLocalImports());
            }
            var type = try {
              Context.getType(typeName).getClass();
            } catch (e:String) {
              throw new DslError('The type ${typeName} was not found', value.pos);
            }
            var f = type.findField(b, true);
            if (f == null) {
              throw new DslError('The field ${typeName}.${b} does not exist', value.pos);
            }
            if (!f.isFinal) {
              throw new DslError('Fields used in pilot.Style MUST be final', value.pos);
            }
            switch f.expr().expr {
              case TConst(TString(s)): s;
              case TConst(TInt(s)): Std.string(s);
              default: throw new DslError('Invalid value', value.pos);
            }
          default: throw new DslError('Invalid value', value.pos);
        }
      case VCall(name, args):
        '${name}(' + [ for (a in args) generateValue(a) ].join(',') + ')';
      case VNumeric(data, unit):
        if (unit == null) {
          data;
        } else {
          data + unit; 
        }
      case VColor(color): '#' + color;
      case VCompound(values): [ for (v in values) generateValue(v) ].join(' ');
      case VString(data): '"' + data + '"';
      // case VBinOp(op, left, right): generateValue(left) + op + generateValue(right);
      case VList(left, right): generateValue(left) + ', ' + generateValue(right);
    }
  }

  static function getTypePath(name:String, imports:Array<ImportExpr>):String {
    // check imports
    for (i in imports) switch i.mode {
      case IAsName(n):
        if (n == name) {
          var name = i.path[i.path.length - 1].name; 
          var pack = [ for (index in 0...i.path.length-1) i.path[index].name ];
          return pack.concat([ name ]).join('.');
        }
      default:
        var n = i.path[i.path.length - 1].name;
        if (n == name) {
          var pack = [ for (index in 0...i.path.length-1) i.path[index].name ];
          return pack.concat([ name ]).join('.');
        }
    }
    // If not found, assume local or full type path.
    return name;
  }

  function generateFontFace(properties:Array<CssExpr>) {
    var out = '@font-face ' + generateDeclaration({
      selector: [ [ {} ] ],
      pos: { min: 0, max: 0 }
    }, properties);
    return out;
  }

  function generateKeyframes(name:String, properties:Array<CssExpr>) {
    var out = '@keyframes ${name} {\n';
    indent();
    out += generateDeclaration({
      selector: [ [ {} ] ],
      pos: { min: 0, max: 0 }
    }, properties);
    outdent();
    out += '\n${getIndent()}}';
    return out;
  }

  function generateMediaQuery(conditions:Array<MediaCondition>, properties:Array<CssExpr>, ?sel:String):String {
    var query = '@media ';
    var decls:Array<String> = [];
    var props:Array<String> = [];
    
    query += [ for (c in conditions) generateMediaQueryCondition(c) ].join(', ');
    
    indent();
    for (prop in properties) switch prop.expr {
      case CPropety(name, value):
        props.push(generateProperty(name, value));
      case CDeclaration(selector, properties):
        var decl = generateDeclaration(selector, properties, sel);
        if (decl != null) decls.push(decl);
      case CMediaQuery(_, _):
        throw new DslError('Nested media queries are not allowed', prop.pos);
      default:
        throw new DslError('Not implented yet', prop.pos);
    }

    if (props.length > 0) {
      if (sel == null) {
        throw new DslError('Media queries must have a parent selector if properties are used', properties[0].pos);
      }
      indent();
      var p = props.map(p -> '${getIndent()}$p').join('\n');
      outdent();
      var decl = '${getIndent()}${sel} {\n${p}\n${getIndent()}}';
      decls.unshift(decl);
    }
    outdent();

    return decls.length > 0 
      ? query + ' {\n' + decls.join('\n') + '\n}' 
      : null;
  }

  function generateMediaQueryCondition(condition:MediaCondition) {
    return switch condition {
      case Negated(cond): 'not ${generateMediaQueryCondition(cond)}';
      case And(a, b): '${generateMediaQueryCondition(a)} and ${generateMediaQueryCondition(b)}';
      case Type(type): type;
      case Feature(name, value): '(${name}: ${generateValue(value)})';
    }
  }

  function generateSelector(selector:Selector, ?parent:String):String {
    var out:Array<String> = [];

    for (option in selector.selector) {
      var foundPlaceholder = false;

      function part(part:SelectorPart) {
        var out = switch part.tag {
          case null | '': '';
          case s: s;
        }

        switch part.id {
          case null | '':
          case id: out += '#${id}';
        }

        if (part.classes != null) for (c in part.classes) {
          out += '.${c}';
        }

        if (part.attrs != null) for (attr in part.attrs) {
          // todo: check on printing value better
          out += '[${attr.name}${attr.op}${attr.value}]';
        }

        if (part.pseudos != null) for (p in part.pseudos) {
          out += generateSelectorPseudo(p);
        }

        if (part.placeholder == true) {
          if (foundPlaceholder) {
            throw new DslError('Only one placeholder allowed per selector option', selector.pos);
          }
          foundPlaceholder = true;
          if (parent == null) {
            throw new DslError('Placeholder requires a parent', selector.pos);
          }
          out = parent + out;
        }

        return out;
      }

      var sel = part(option[0]);

      for (i in 1...option.length) {
        sel += (switch option[i - 1].combinator {
          case null: ' ';
          case v: ' $v ';
        }) + part(option[i]);
      }

      if (!foundPlaceholder) switch parent {
        case null | '':
        case parent: sel = parent + ' ' + sel;
      }

      out.push(sel);
    }

    return out.join(', ');
  }

  function generateSelectorPseudo(pseudo:Pseudo):String {
    return switch pseudo {
      case Vendored(s): s;
      case Dir(s): ':dir($s)';
      case Lang(s): ':name($s)';
      // case NthChild(factor, offset): ':nth-child(${args(factor, offset)})';
      // case NthLastChild(factor, offset): ':nth-last-child(${args(factor, offset)})';
      // case NthLastOfType(factor, offset): ':nth-last-of-type(${args(factor, offset)})';
      // case NthOfType(factor, offset): ':nth-of-type(${args(factor, offset)})';
      case Has(s): ':has(${generateSelector(s)})';
      case Is(s): ':is(${generateSelector(s)})';
      case Not(s): ':not(${generateSelector(s)})';
      case Where(s): ':where(${generateSelector(s)})';
      case Active: ':active';
      case AnyLink: ':any-link';
      case Blank: ':blank';
      case Checked: ':checked';
      case Current: ':current';
      case Default: ':default';
      case Defined: ':defined';
      case Disabled: ':disabled';
      case Drop: ':drop';
      case Empty: ':empty';
      case Enabled: ':enabled';
      case FirstChild: ':first-child';
      case FirstOfType: ':first-of-type';
      case Fullscreen: ':fullscreen';
      case Future: ':future';
      case Focus: ':focus';
      case FocusVisible: ':focus-visible';
      case FocusWithin: ':focus-within';
      case Hover: ':hover';
      case Indeterminate: ':indeterminate';
      case InRange: ':in-range';
      case Invalid: ':invalid';
      case LastChild: ':last-child';
      case LastOfType: ':last-of-type';
      case Link: ':link';
      case LocalLink: ':local-link';
      case OnlyChild: ':only-child';
      case OnlyOfType: ':only-of-type';
      case Optional: ':optional';
      case OutOfRange: ':out-of-range';
      case Past: ':past';
      case PlaceholderShown: ':placeholder-shown';
      case ReadOnly: ':read-only';
      case ReadWrite: ':read-write';
      case Required: ':required';
      case Right: ':right';
      case Root: ':root';
      case Scope: ':scope';
      case Target: ':target';
      case TargetWithin: ':target-within';
      case UserInvalid: ':user-invalid';
      case Valid: ':valid';
      case Visited: ':visited';
      case GrammarError: '::grammar-error';
      case Marker: '::marker';
      case Placeholder: '::placeholder';
      case Selection: '::selection';
      case SpellingError: '::spelling-error';
      case After: '::after';
      case Before: '::before';
      case Cue: '::cue';
      case FirstLetter: '::first-letter';
      case FirstLine: '::first-line';
      default:
        throw 'Not Implemented Yet';
    }
  }

  function indent() {
    indentSize++;
  }

  function outdent() {
    if (indentSize > 0) indentSize--;
  }

  function getIndent() {
    var out = '';
    for (i in 0...indentSize) {
      out += '  ';
    }
    return out;
  }

}

#end
