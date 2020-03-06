package pilot.dsl;

import pilot.dsl.MarkupNode;

using StringTools;

typedef MarkupParserOptions = {
  noInlineControlFlow:Bool
};

class MarkupParser extends Parser<Array<MarkupNode>> {

  final options:MarkupParserOptions;

  public function new(options, source, fileName, filePos) {
    super(source, fileName, filePos);
    this.options = options;
  }

  override function parse():Array<MarkupNode> {
    var out:Array<MarkupNode> = [
      while (!isAtEnd()) parseRoot(false)
    ].filter(n -> n != null);
    if (out.length == 0) {
      out.push({
        node: MNone,
        pos: getPos(position, position)
      });
    }
    return out;
  }

  function parseRoot(allowControlNodes = true):MarkupNode {
    whitespace();
    return switch advance() {
      case '/' if (match('/')):
        ignoreLine();
        null;
      case '<' if (match('/')): 
        throw errorAt('Unexpected close tag', '</');
      case '<': parseNode();
      case '@' if (!options.noInlineControlFlow): parseInlineCode();
      case '$': parseCodeBlock(0);
      case '{': parseCodeBlock(1);
      default: parseText(previous());
    }
  }

  function parseInlineCode():MarkupNode {
    var start = position;
    
    if (checkAny([ 'if', 'for', 'switch' ])) {
      var isIf = match('if');
      var isFor = match('for');
      var isSwitch = match('switch');
      var hasElse = false;

      function readCode() {
        readWhile(() -> !checkAny([ '{', '<' ]));
        if (match('<')) {
          if (isSwitch) {
            throw error('`@switch` requires brackets', start, position);
          }
          parseNode();
        } else {
          consume('{');
          parseCode(1);
        }
      }

      readCode();
      whitespace();

      if (match('else')) {
        if (!isIf) {
          throw errorAt('`else` is only allowed for @if blocks', 'else');
        }
      
        hasElse = true;
        readCode();
      }

      var code = source.substring(start, position);
      
      if (isIf && !hasElse) {
        code += ' else null';
      } else if (isFor) {
        code = '[${code}]';
      }
      
      // Currently this syntax works by just passing a string to the
      // generator, where it gets parsed. That feels wrong: we should
      // consider passing expressions instead of strings with MCode and
      // handle all parsing and reentrency here in the MarkupParser.
      return {
        node: MCode(code),
        pos: getPos(start, position)
      };
    } else {
      readWhile(() -> !isWhitespace(peek()));
      throw error('Only `@if`, `@switch` or `@for` are allowed here', start, position);
    }
  }

  function parseNode():MarkupNode {
    var start = position - 1;
    var name:String;
    var attrs:Array<MarkupAttribute> = [];
    var children:Array<MarkupNode> = null;

    if (match('>')) {
      whitespace();
      children = [];
      var didClose = false;
      var isClosed = () -> didClose = match('</>'); 
      while (!isAtEnd() && !isClosed()) {
        var n = parseRoot();
        if (n != null) children.push(n);
        whitespace();
      }
      if (!didClose) {
        throw error('Unclosed fragment', start, position);
      }
      return {
        node: MFragment(children),
        pos: getPos(start, position)
      };
    }

    name = path();
    
    whitespace();

    while (!check('>') && !isAtEnd()) {
      if (match('//')) {
        ignoreLine();
        whitespace();
        continue;
      }

      if (check('/')) {
        break;
      }

      var attrStart = position;
      var key:String = (match('@') ? '@' : '') + ident();
      if (key.length <= 0) {
        throw errorAt('Expected an identifier', peek());
      }

      consume('=');
      whitespace();
      var valueStart = position;
      var value = {
        value: parseValue(),
        pos: getPos(valueStart, position)
      };
      whitespace();

      attrs.push({
        name: key,
        value: value,
        pos: getPos(attrStart, position)
      });
    }

    if (!match('/>')) {
      consume('>');
      whitespace();
      children = parseChildren(name);
    }

    return {
      node: MNode(
        name,
        attrs,
        children,
        isUcAlpha(name.charAt(0)) || name.contains('.')
      ),
      pos: getPos(start, position)
    };
  }

  function parseChildren(closeTag:String):Array<MarkupNode> {
    var start = position;
    var children:Array<MarkupNode> = [];
    var didClose = false;
    var isClosed = () -> didClose = match('</${closeTag}>');

    whitespace();

    while (!isAtEnd() && !isClosed()) {
      var n = parseRoot();
      if (n != null) children.push(n);
      whitespace();
    }

    if (!didClose) {
      throw error('Unclosed tag: ${closeTag}', start, position);
    }

    return children;
  }

  function parseText(init:String):MarkupNode {
    var start = position;
    var token = options.noInlineControlFlow
      ? [ '<', '$', '{' ]
      : [ '<', '$', '{', '@' ];
    var out = init + readWhile(() -> !checkAnyUnescaped(token));

    out = out
      .replace('\\@', '@')
      .replace('\\$', '$')
      .replace('\\{', '{')
      .replace('\\<', '<');

    if (out.trim().length == 0) {
      return {
        node: MNone,
        pos: getPos(start, position)
      }
    }

    return {
      node: MText(out),
      pos: getPos(start, position)
    };
  }

  function checkAnyUnescaped(items:Array<String>) {
    for (item in items) {
      if (check(item)) {
        if (previous() == '\\') return false;
        return true;
      }
    }
    return false;
  }

  function parseCodeBlock(braces:Int):MarkupNode {
    var start = position;
    var out:String = parseCode(braces);

    return {
      node: MCode(out),
      pos: getPos(start, position)
    };
  }

  function parseValue():MarkupAttributeValue {
    return switch advance() {
      case '$': Code(parseCode(0));
      case '{': Code(parseCode(1));
      case '"': Raw(string('"'));
      case "'": Raw(string("'"));
      default: 
        if (check('{')) {
          Code(parseCode(0));
        } else {
          throw errorAt('Expected a string, `$${...}` or `{...}`', peek());
        }
    }
  }

  function path() {
    return readWhile(() -> isAlphaNumeric(peek()) || checkAny([ '.', '-', '_' ]));
  }

  override function isAllowedInIdentifier(s:String) {
    return isAlphaNumeric(s) || checkAny([ '-', '_', ':' ]);
  } 

}
