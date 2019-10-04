package pilot;

enum Hook {

  /**
    Run at the start of every patch, for every VNode, regardless
    of if the VNode needs to be patched or not.
  **/
  HookPre(cb:()->Void);

  /**
    Run at the end of every patch, for every VNode, regardless
    of if the VNode needs to be patched or not.
  **/
  HookPost(cb:()->Void);

  /**
    Invoked before a VNode is patched. If the differ did not
    detect any changes, this won't be invoked.
  **/
  HookPrePatch(cb:(oldVn:VNode, newVn:VNode)->Void);

  /**
    Invoked after a VNode is patched. If the differ did not
    detect any changes, this won't be invoked.
  **/
  HookPostPatch(cb:(oldVn:VNode, newVn:VNode)->Void);

  /**
    Invoked when a node is removed from the dom. Does NOT
    bubble.
  **/
  HookRemove(cb:(vn:VNode)->Void);

  /**
    Invoked when a node is removed from the dom. Will
    be also bubbled to all children. 
  **/
  HookDestroy(cb:(vn:VNode)->Void);

  /**
    Invoked when a node is created for the first time. Note that
    this will NOT be invoked if any matching DOM exists, even if
    its the first time `Differ.patch` is called.
  **/
  HookCreate(cb:(vn:VNode)->Void);

  /**
    Invoked when a node will be updated (BEFORE any changes are
    applied). Also invoked when a node is created, in which case
    `oldVn` will be null.
  **/
  HookUpdate(cb:(oldVn:Null<VNode>, newVn:VNode)->Void);

  /**
    Invoked after a node is inserted into the DOM.
  **/
  HookInsert(cb:(vn:VNode)->Void);

}
