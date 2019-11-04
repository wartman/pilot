package pilot.core;

interface Registry<K, V> {
  public function put(?key:K, value:V):Void;
  public function pull(?key:K):V;
  public function exists(key:K):Bool;
}
