package pilot.dsl;

import pilot.dsl.MarkupNode;

using StringTools;

class MarkupParser extends Parser<Array<MarkupNode>> {

  override function parse():Array<MarkupNode> {
    var out:Array<MarkupNode> = [];
    while (!isAtEnd()) out.push(parseRoot());
    if (out.length == 0) {
      out.push({
        node: MNone,
        pos: getPos(position, position)
      });
    }
    return out;
  }

  function parseRoot():MarkupNode {
    whitespace();
    return switch advance() {
      case '/' if (match('/')):
        ignoreLine();
        null;
      case '<' if (match('for')): parseFor();
      case '<' if (match('if')): parseIf();
      case '<' if (match('/')): 
        throw error('Unexpected close tag', position - 1, position + 1);
      case '<': parseNode();
      case '$': parseCodeBlock(0);
      case '{': parseCodeBlock(1);
      default: parseText(previous());
    }
  }

  function parseFor():MarkupNode {
    var start = position - 4;

    whitespace();

    var it = switch advance() {
      case '{': parseCode(1);
      case '$': parseCode(0);
      default:
        throw error('<for> requires an iterator', position - 1, position);
    }

    whitespace();

    if (match('/>')) {
      throw error('<for> cannot be a void tag', start, position);
    }

    consume('>');
    whitespace();
    
    var children = parseChildren('for');
    
    return {
      node: MFor(it, children),
      pos: getPos(start, position)
    };
  }

  function parseIf():MarkupNode {
    var start = position - 3;
    var hasElseBranch:Bool = false;
    var didClose:Bool = false;
    var endThenBranch = () -> {
      if (match('<else>')) {
        hasElseBranch = true;
        didClose = true;
        return true;
      }
      return didClose = match('</if>');
    };
    var passing:Array<MarkupNode> = [];
    var failed:Array<MarkupNode> = [];
    var cond:String = '';

    whitespace();

    cond = switch advance() {
      case '{': parseCode(1);
      case '$': parseCode(0);
      default:
        throw error('<if> requires a condition', position - 1, position);
    }

    whitespace();

    if (match('/>')) {
      throw error('<if> cannot be a void tag', start, position);
    }
    
    consume('>');
    whitespace();

    while (!isAtEnd() && !endThenBranch()) {
      passing.push(parseRoot());
      whitespace();
    }

    if (!didClose) {
      throw error('Unclosed <if>', start, position);
    }

    if (hasElseBranch) {
      failed = parseChildren('if');
    } else {
      failed = null;
    }

    return {
      node: MIf(cond, passing, failed),
      pos: getPos(start, position)
    };
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
        children.push(parseRoot());
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

    while (!(peek() == '>') && !isAtEnd()) {
      if (match('//')) {
        ignoreLine();
        whitespace();
        continue;
      }

      if (peek() == '/') {
        break;
      }

      var attrStart = position;
      var key:String = ident();

      // whitespace();
      // if (match('.')) key = '.';
      // key += ident();
      // whitespace();
      consume('=');
      whitespace();
      var value = parseValue();
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
      children.push(parseRoot());
      whitespace();
    }

    if (!didClose) {
      throw error('Unclosed tag: ${closeTag}', start, position);
    }

    return children;
  }

  function parseText(init:String):MarkupNode {
    var start = position;
    var out = init;

    while (
      !isAtEnd() 
      // todo: allow escapes
      && peek() != '<'
      && peek() != '$'
      && peek() != '{'
    ) {
      out += advance();
    }

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
        if (peek() == '{') {
          Code(parseCode(0));
        } else {
          throw error('Expected a string, `$${...}` or `{...}`', position, position);
        }
    }
  }

  function string(delimiter:String) {
    var out = '';
    var start = position;

    while (!isAtEnd() && !match(delimiter)) {
      out += advance();
      if (previous() == '\\' && !isAtEnd()) {
        out += '\\${advance()}';
      }
    }

    if (isAtEnd()) 
      throw error('Unterminated string', start, position);
    
    return out;
  }

  function parseCode(braces:Int):String {
    var out:String = '';
    if (match('{')) braces++;
    
    if (braces >= 1) {
      while (!isAtEnd() && braces != 0) {
        var add = advance();
        if (add == '{') braces++;
        if (add == '}') braces--;
        if (braces == 0) break;
        out += add;
      }
    } else {
      out = ident();
    }

    return out;
  }

  function ident() {
    return [ 
      while ((isAlphaNumeric(peek()) || peek() == '-') && !isAtEnd()) advance() 
    ].join('');
  }

  function path() {
    return [ 
      while ((isAlphaNumeric(peek()) || peek() == '.' || peek() == '-') && !isAtEnd()) advance() 
    ].join('');
  }

}
