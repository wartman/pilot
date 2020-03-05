package pilot.message;

typedef Update<Action, Data> = {
  public function __updateData(action:Action, data:Data):Null<Data>;
}
