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
using pbpgui

const class ChangeTableUpdater : Actor
{
  const Str tableHandler := Uuid().toStr
  const Watcher watcher

  new make(Table tabletoupdate, Watcher watcher) : super(ActorPool())
  {
    Actor.locals[tableHandler] = tabletoupdate
    this.watcher = watcher
  }

  override Obj? receive(Obj? msg)
  {
      if(watcher.check)
      {

        Desktop.callAsync |->|{
          updateTable()
        }
      }
    sendLater(1ms, null)
    return null
  }

  Void updateTable()
  {
    table := Actor.locals[tableHandler] as Table
    if(table != null)
    {
      (table.model as ChangesetTableModel).update
      table.refreshAll
    }
  }

}
