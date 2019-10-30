package pilot2.dsl;

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
    while (isWhitespace(peek()) && !isAtEnd()) advance();
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

  function ignore(names:Array<String>) {
    for (name in names) match(name);
  }

  function match(value:String) {
    var check = source.substr(position, value.length);
    if (check == value) {
      position = position + value.length;
      return true;
    }
    return false;
  }

  function consume(value:String) {
    var start = position;
    if (!match(value)) error('Expected ${value}', start, position);
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
    throw new DslError(msg, getPos(min, max));
  }

  function getPos(min:Int, max:Int):{ min:Int, max:Int } {
    return {
      min: filePos + min,
      max: filePos + max
    }
  }

}