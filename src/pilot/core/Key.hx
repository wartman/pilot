package pilot.core;

abstract Key({}) from {} to {} {
  
  @:from public static function ofFloat(f:Float):Key {
    return Std.string(f);
  }

  public function isString() {
    return Std.is(this, String);
  }

}
