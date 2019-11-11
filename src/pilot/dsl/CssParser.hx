package pilot.dsl;

import pilot.dsl.CssExpr;

class CssParser extends Parser<Array<CssExpr>> {

  static final OPERATORS = [
    for (op in [WhitespaceSeperated, HyphenSeparated, BeginsWith, EndsWith, Contains, Exactly])
      (op:String) => op
  ];

  static final PSEUDO_ELEMENT = [
    'after' => After,
    'before' => Before,
    'cue' => Cue,
    'first-letter' => FirstLetter,
    'first-line' => FirstLine,
  ];

  static final PSEUDO_ELEMENT_STRICT = [
    'grammar-error' => GrammarError,
    'marker' => Marker,
    'placeholder' => Placeholder,
    'selection' => Selection,
    'spelling-error' => SpellingError,
  ];

  static final PSEUDO_CLASS = [
    'odd' => NthChild(2, 1),
    'even' => NthChild(2, 0),
    'active' => Active,
    'any-link' => AnyLink,
    'blank' => Blank,
    'checked' => Checked,
    'current' => Current,
    'default' => Default,
    'defined' => Defined,
    'disabled' => Disabled,
    'drop' => Drop,
    'empty' => Empty,
    'enabled' => Enabled,
    'first-child' => FirstChild,
    'first-of-type' => FirstOfType,
    'fullscreen' => Fullscreen,
    'future' => Future,
    'focus' => Focus,
    'focus-visible' => FocusVisible,
    'focus-within' => FocusWithin,
    'hover' => Hover,
    'indeterminate' => Indeterminate,
    'in-range' => InRange,
    'invalid' => Invalid,
    'last-child' => LastChild,
    'last-of-type' => LastOfType,
    'link' => Link,
    'local-link' => LocalLink,
    'only-child' => OnlyChild,
    'only-of-type' => OnlyOfType,
    'optional' => Optional,
    'out-of-range' => OutOfRange,
    'past' => Past,
    'placeholder-shown' => PlaceholderShown,
    'read-only' => ReadOnly,
    'read-write' => ReadWrite,
    'required' => Required,
    'right' => Right,
    'root' => Root,
    'scope' => Scope,
    'target' => Target,
    'target-within' => TargetWithin,
    'user-invalid' => UserInvalid,
    'valid' => Valid,
    'visited' => Visited,
  ];

  static final PSEUDO_CLASS_CONFIGURABLE = [
    'has' => Has,
    'is' => Is,
    'not' => Not,
    'where' => Where,
  ];

  static final PSEUDO_CLASS_NUMERIC = [
    'nth-child' => NthChild,
    'nth-last-child' => NthLastChild,
    'nth-last-of-type' => NthLastOfType,
    'nth-of-type' => NthOfType,
  ];
  
  override function parse():Array<CssExpr> {
    return [ while (!isAtEnd()) parseDeclaration() ];
  }

  function parseDeclaration():CssExpr {
    whitespace();

    if (isAtEnd()) {
      return null;
    }
    
    if (match('//')) {
      ignoreLine();
      return parseDeclaration();
    }

    if (match('/*')) {
      while (!match('*/') && !isAtEnd()) advance();
      return parseDeclaration();
    }

    if (match('@media')) {
      return parseMediaQuery();
    }

    if (match('@fontface')) {
      throw errorAt('Not implemented yet', '@fontface');
    }

    if (match('@keyframes')) {
      throw errorAt('Not implemented yet', '@keyframes');
    }

    return switch attempt(() -> {
      var start = position;
      var id = ident();
      if (id.length == 0) return None;
      whitespace();
      consume(':');
      whitespace();
      var value = parseValue();
      consume(';');
      return Some(({
        expr: CPropety(id, value),
        pos: getPos(start, position)
      }:CssExpr));
    }) {
      case Some(v): v;
      case None: parseRule();
    }
  }

  function parseRule():CssExpr {
    whitespace();
    if (isAtEnd()) return null; // ?

    var start = position;
    var selector = parseSelector();
    var properties = parseBody();

    return {
      expr: CDeclaration(selector, properties),
      pos: getPos(start, position)
    };
  }

  function parseBody():Array<CssExpr> {
    var start = position;
    var properties:Array<CssExpr> = [];
    var didClose = false;

    function isClosed() {
      return didClose = match('}');
    }

    whitespace();
    consume('{');
    whitespace();
    
    while (!isAtEnd() && !isClosed()) {
      whitespace();
      properties.push(parseDeclaration());
      whitespace();
    }

    if (!didClose) {
      throw error('Unclosed rule', start, position);
    }

    return properties;
  }

  function parseMediaQuery():CssExpr {
    var start = position;
    var conditions = parseMediaConditions();
    var properties = parseBody();
    return {
      expr: CMediaQuery(conditions, properties),
      pos: getPos(start, position)
    };
  }

  function parseMediaType():MediaCondition {
    return Type(switch ident() {
      case v = All | Print | Screen | Speech: cast v;
      case v: throw reject(v);
    });
  }

  function parseMediaFeature():MediaCondition {
    var id = ident();
    whitespace();
    consume(':');
    whitespace();
    var value = parseValue(')');
    whitespace();
    consume(')');
    return Feature(id, value);
  }

  function parseMediaCondition() {
    var negated = false;
    whitespace();
    if (match('not')) {
      negated = true;
      whitespace();
    }
    var cond = if (match('(')) {
      parseMediaFeature();
    } else {
      parseMediaType();
    }
    whitespace();
    cond = if (negated) Negated(cond) else cond;
    if (match('and')) {
      cond = And(cond, parseMediaCondition());
    }
    return cond;
  }

  function parseMediaConditions():Array<MediaCondition> {
    return [ do parseMediaCondition() while (match(',') && !isAtEnd()) ];
  }

  function parseSelector():Selector {
    var start = position;
    return {
      selector: [ do {
        whitespace();
        var sel = parseSelectorOption();
        if (sel.length == 0) {
          throw errorAt('Selector expected', peek());
        }
        sel;
      } while (match(',')) ],
      pos: getPos(start, position)
    };
  }

  function parseSelectorOption():SelectorOption {
    var ret:Array<SelectorPart> = [];
    while(!isAtEnd() && isSelectorStart()) {
      var part = parseSelectorPart();
      var start = position;
      whitespace();
      part.combinator = 
        if (match('~')) GeneralSibling;
        else if (match('+')) AdjacentSibling;
        else if (match('>')) Child;
        else Descendant;
      ret.push(part);
      whitespace();
      if (start == position) break;
    }
    return ret;
  }

  function isSelectorStart() {
    return checkAny([
      '_', '#', '*', ':', '[', '.', '&'
    ]) || isAlphaNumeric(peek());
  }

  function parseSelectorPart():SelectorPart {
    return parseSelectorPartNext(switch ident() {
      case null: 
        if (match('*')) advance();
        null;
      case s: s;
    });
  }

  function parseSelectorPartNext(tag:String):SelectorPart {
    var ret:SelectorPart = {
      tag: tag,
      id: null,
      classes: [],
      attrs: [],
      pseudos: []
    };
    while (!isAtEnd()) {
      if (match('#')) {
        if (ret.id != null) {
          throw errorAt('Cannot have multiple ids (already have ${ret.id})', previous());
        }
        ret.id = ident();
      } else if (match(':')) {
        ret.pseudos.push(parseSelectorPseudo());
      } else if (match('[')) {
        var name = ident();
        whitespace();
        ret.attrs.push(
          if (match(']')) 
            { name: name, op: None, value: null }
          else
            {
              name: name,
              op: parseAttrOp(),
              value: {
                whitespace();
                var value = ident();
                whitespace();
                consume(']');
                value;
              }
            }
        );
      } else if (match('.')) {
        ret.classes.push(ident());
      } else if (match('&')) {
        ret.placeholder = true;
      } else {
        break;
      }
    }
    return ret;
  }

  function parseAttrOp():AttrOperator {
    for (key => op in OPERATORS) {
      if (match(key)) return op;
    }
    throw errorAt('Expected an operator', peek());
  }

  function parseSelectorPseudo():Pseudo {
    var isClass = !match(':');
    var name = ident();
    if (!isClass && match('-')) {
      return Vendored(name);
    }

    return switch name {
      case 'lang' if (isClass):
        consume('(');
        whitespace();
        var out = Lang(ident());
        whitespace();
        consume(')');
        out;
      case 'dir' if (isClass):
        consume('(');
        whitespace();
        var dir = match(Rtl)
          ? Rtl
          : match(Ltr)
            ? Ltr
            : throw errorAt('Expected $Rtl or $Ltr', peek());
        var out = Dir(dir);
        whitespace();
        consume(')');
        out;
      case PSEUDO_ELEMENT[_] => found if (found != null): found;
      case PSEUDO_ELEMENT_STRICT[_] => found if (!isClass && found != null): found;
      case PSEUDO_CLASS[_] => found if (isClass && found != null): found;
      case PSEUDO_CLASS_CONFIGURABLE[_] => ctor if (isClass && ctor != null):
        consume('(');
        whitespace();
        var out = ctor(parseSelector());
        whitespace();
        consume(')');
        out;
      case PSEUDO_CLASS_NUMERIC[_] => ctor if (isClass && ctor != null):
        // consume('(');
        // whitespace();
        // var out = ctor(parseInt());
        // whitespace();
        // consume(')');
        // out;
        throw errorAt('Not implemented', previous());
      default:
        throw reject(name);
    }
  }
  
  // TODO: Need to implement a real parser, this one
  //       is a mess. The `until` param is a hack to allow
  //       us to read arbitrary strings of code.
  function parseValue(until = ';'):Value {
    var start = position;
    var value = switch attempt(() -> switch advance() {
      case '$': Some(Code(parseCode(0)));
      // case '{': Some(Code(parseCode(1)));
      case '"': Some(Raw( '"' + string('"') + '"' ));
      case "'": Some(Raw( "'" + string("'") + "'" ));
      default: None;
    }) {
      case Some(v): v;
      case None: switch attempt(() -> {
        // TODO: this is a hack, implement real calling
        var id = ident();
        consume('(');
        var value = switch parseValue(')').value {
          case Raw(v): v;
          case Code(_): throw 'not implemented';
        }
        consume(')');
        Some('$id($value)');
      }) {
        case Some(v): Raw(v);
        // TODO: this is a hack, actually parse values!
        case None: Raw(readWhile(s -> s != until));
      }
    }

    return {
      value: value,
      pos: getPos(start, position)
    };
  }

}
