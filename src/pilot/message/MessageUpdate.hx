package pilot.message;

typedef MessageUpdate<Action, Data> = {
  public function __updateData(action:Action, data:Data):Null<Data>;
}
