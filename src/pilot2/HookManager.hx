package pilot2;

@:forward
abstract HookManager(Array<Hook>) from Array<Hook> {

  public function new(hooks:Array<Hook>) {
    this = hooks;
  }

  public inline function add(hook:Hook) {
    this.push(hook);
  }
  
  public function doPreHook() Scheduler.enqueue(() -> {
    for (hook in this) switch hook {
      case HookPre(cb): cb();
      default:
    }
  });

  public function doPostHook() Scheduler.enqueue(() -> {
    for (hook in this) switch hook {
      case HookPost(cb): cb();
      default:
    }
  });

  public function doRemoveHook(vn:VNode) Scheduler.enqueue(() -> {
    for (hook in this) switch hook {
      case HookRemove(cb): cb(vn);
      default:
    }
  });

  public function doDestroyHook(vn:VNode) Scheduler.enqueue(() -> {
    for (hook in this) switch hook {
      case HookDestroy(cb):
        switch vn.type {
          case VNodeElement(_, _, children):
            for (c in children) c.hooks.doDestroyHook(c);
          default:
        }
        cb(vn);
      default:
    }
  });

  public function doCreateHook(vn:VNode) Scheduler.enqueue(() -> {
    for (hook in this) switch hook {
      case HookCreate(cb): cb(vn);
      default:
    }
  });

  public function doUpdateHook(oldVn:VNode, newVn:VNode) Scheduler.enqueue(() -> {
    for (hook in this) switch hook {
      case HookUpdate(cb): cb(oldVn, newVn);
      default:
    }
  });

  public function doInsertHook(vn:VNode) Scheduler.enqueue(() -> {
    for (hook in this) switch hook {
      case HookInsert(cb): cb(vn);
      default:
    }
  });

  public function doPrePatchHook(oldVn:VNode, newVn:VNode) Scheduler.enqueue(() -> {
    for (hook in this) switch hook {
      case HookPrePatch(cb): cb(oldVn, newVn);
      default:
    }
  });

  public function doPostPatchHook(oldVn:VNode, newVn:VNode) Scheduler.enqueue(() -> {
    for (hook in this) switch hook {
      case HookPostPatch(cb): cb(oldVn, newVn);
      default:
    }
  });

}
