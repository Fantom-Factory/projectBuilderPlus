/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbpcore
using fwt
using gfx

**
** A UI component that can be updated
**
mixin UiUpdatable
{
  abstract Void updateUi(Obj? param := null)
}

** UiUpdater
** Generic actor that takes upon refreshing a UI element
**
const class UiUpdater : Actor
{
  const Str uuid := Uuid().toStr
  const Watcher watcher
  const AtomicBool stop := AtomicBool(false)

  new make(UiUpdatable ui, Watcher watcher) : super(ActorPool())
  {
    Actor.locals[uuid] = ui
    this.watcher = watcher
  }

  override Obj? receive(Obj? msg)
  {
    if (stop.val) { return null }

    if(watcher.check)
    {
      Desktop.callAsync |->|
      {
        update(msg)
      }
    }
    sendLater(1ms, null)
    return null
  }

  Void update(Obj? obj := null)
  {
    updatable := Actor.locals[uuid] as UiUpdatable
    if(updatable != null)
    {
      updatable.updateUi(obj)
    }
  }
}
