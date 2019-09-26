package pilot2;

enum Hook {
  // HookBefore(cb:()->Void);
  // HookAfter(cb:()->Void);
  HookRemove(cb:(vn:VNode)->Void);
  HookCreate(cb:(vn:VNode)->Void);
  // HookUpdate(cb:(oldVn:VNode, newVn:VNode)->Void);
  HookPrePatch(cb:(oldVn:VNode, newVn:VNode)->Void);
  HookPostPatch(cb:(oldVn:VNode, newVn:VNode)->Void);
}
