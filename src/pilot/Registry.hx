package pilot;

interface Registry<K, V> {
  public function put(?key:K, value:V):Void;
  public function pull(?key:K):V;
  public function exists(key:K):Bool;
  public function each(cb:(value:V)->Void):Void;
}
