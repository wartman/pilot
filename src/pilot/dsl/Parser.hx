package pilot.dsl;

import haxe.ds.Option;

class Parser<T> {
  
  final source:String;
  final fileName:String;
  final filePos:Int;
  var position:Int = 0;

  public function new(
    source:String,
    fileName:String,
    filePos:Int
  ) {
    this.source = source;
    this.fileName = fileName;
    this.filePos = filePos;
  }

  public function parse():T {
    throw 'abstract';
    return null;
  }

  function ignoreLine() {
    while (!isAtEnd() && !match('\n')) advance();
  }

  function whitespace() {
    readWhile(() -> isWhitespace(peek()));
  }
  
  function isWhitespace(c:String) {
    return c == ' ' || c == '\n' || c == '\r' || c == '\t';
  }

  function isDigit(c:String):Bool {
    return c >= '0' && c <= '9';
  }

  function isUcAlpha(c:String):Bool {
    return (c >= 'A' && c <= 'Z');
  }

  function isAlpha(c:String):Bool {
    return (c >= 'a' && c <= 'z') ||
           (c >= 'A' && c <= 'Z') ||
            c == '_';
  }

  function isAlphaNumeric(c:String) {
    return isAlpha(c) || isDigit(c);
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

  function ident() {
    return readWhile(() -> isAllowedInIdentifier(peek()));
  }

  function isAllowedInIdentifier(s:String) {
    return isAlphaNumeric(s) || checkAny([ '-', '_' ]);
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

  function attempt<T>(cb:()->Option<T>):Option<T> {
    var start = position;
    // var o = try cb() catch (e:DslError) None;
    var o = cb();
    return switch o {
      case Some(v): 
        Some(v);
      case None: 
        position = start;
        None;
    }
  }

  function readWhile(compare:()->Bool):String {
    var out = [ while (!isAtEnd() && compare()) advance() ];
    return out.join('');
  }

  function ignore(names:Array<String>) {
    for (name in names) match(name);
  }

  /**
    Check a value AND consume it.
  **/
  function match(value:String) {
    if (check(value)) {
      position = position + value.length;
      return true;
    }
    return false;
  }

  /**
    Check against a number of values value AND consume it.
  **/
  function matchAny(values:Array<String>) {
    for (v in values) {
      if (match(v)) return true;
    }
    return false;
  }

  /**
    Check if the value is coming up next (and do NOT consume it).
  **/
  function check(value:String) {
    var found = source.substr(position, value.length);
    return found == value;
  }

  /**
    Check if any of the values are coming up next (and do NOT consume it).
  **/
  function checkAny(values:Array<String>) {
    for (v in values) {
      if (check(v)) return true;
    }
    return false;
  }

  function consume(value:String) {
    if (!match(value)) throw expected(value);
  }

  function peek() {
    return source.charAt(position);
  }

  function advance() {
    if (!isAtEnd()) position++;
    return previous();
  }

  function previous() {
    return source.charAt(position - 1);
  }

  function isAtEnd() {
    return position == source.length;
  }

  function error(msg:String, min:Int, max:Int) {
    return new DslError(msg, getPos(min, max));
  }

  function errorAt(msg:String, value:String) {
    return error(msg, position - value.length, position);
  }

  function reject(s:String) {
    return error('Unexpected [${s}]', position, position + s.length);
  }

  function expected(s:String) {
    return error('Expected [${s}]', position, position + 1);
  }

  function getPos(min:Int, max:Int):DslPosition {
    return {
      min: filePos + min,
      max: filePos + max
    }
  }

}