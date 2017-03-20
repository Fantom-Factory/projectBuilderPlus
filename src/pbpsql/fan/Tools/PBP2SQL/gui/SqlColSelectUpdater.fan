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
using pbplogging

const class SqlColSelectUpdater : Actor
{
  const Str sqlColSelectHandler := Uuid().toStr
  const Watcher watcher

  new make(SqlColSelector selectortoupdate, Watcher watcher, ActorPool pool) : super(pool)
  {
    Actor.locals[sqlColSelectHandler] = selectortoupdate
    this.watcher = watcher
  }

  override Obj? receive(Obj? msg)
  {
    if(watcher.check)
    {
    Desktop.callAsync |->|{
      updateSelector()
    }
    }
    sendLater(1ms, null)
    return null
  }

  Void updateSelector()
  {
    combo := Actor.locals[sqlColSelectHandler] as SqlColSelector
    if(combo != null)
    {
      //Logger.log.debug(combo.listRef.val)
      Logger.log.debug("updating")
      combo.update()
      combo.repaint
    }
  }

}
