package pilot.dsl;

import pilot.dsl.MarkupNode;

using StringTools;

class MarkupParser extends Parser<Array<MarkupNode>> {

  override function parse():Array<MarkupNode> {
    var out:Array<MarkupNode> = [];
    while (!isAtEnd()) out.push(parseRoot(false));
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
      case '<' if (match('for')):
        if (!allowControlNodes) 
          throw errorAt('<for> cannot be a root node', 'for');
        parseFor();
      case '<' if (match('if')):
        if (!allowControlNodes) 
          throw errorAt('<if> cannot be a root node', 'if');
        parseIf();
      case '<' if (match('/')): 
        throw errorAt('Unexpected close tag', '</');
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
        throw errorAt('<for> requires an iterator', previous());
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
      var key:String = ident();
      if (key.length <= 0) {
        throw errorAt('Expected an identifier', peek());
      }
      var macroName = if (match('@')) ident() else null;

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
        macroName: macroName,
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
    // todo: allow escapes
    var out = init + readWhile(_ -> !checkAny([ '<', '$', '{' ]));

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
        if (check('{')) {
          Code(parseCode(0));
        } else {
          throw errorAt('Expected a string, `$${...}` or `{...}`', peek());
        }
    }
  }

  function path() {
    return readWhile(s -> isAlphaNumeric(s) || checkAny([ '.', '-', '_' ]));
  }

}
