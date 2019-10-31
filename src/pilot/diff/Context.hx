package pilot.diff;

interface Context<Real:{}> {
  public function setPreviousRender(node:Real, render:RenderResult<Real>):Void;
  public function getPreviousRender(node:Real):RenderResult<Real>;
  public function removePreviousRender(node:Real, recursive:Bool = false):Void;
  public function getChildren(node:Real):Array<Real>;
  public function addChild(node:Real, child:Real):Void;
  public function removeChild(node:Real, child:Real):Void;
  public function insertBefore(parent:Real, target:Real, node:Real):Void;
}
