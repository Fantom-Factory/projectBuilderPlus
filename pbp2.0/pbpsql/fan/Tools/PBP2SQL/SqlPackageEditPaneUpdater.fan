/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using pbpcore
using gfx
using pbplogging

const class SqlPackageEditPaneUpdater : Actor, Logging
{
  const Str[] sqlEditPaneHandlers
  const Watcher watcher
  new make(SqlPackageEditPane[] panes, Watcher watcher, ActorPool pool) : super(pool)
  {
    this.watcher = watcher
    Str[] handlers := [,]
    panes.each |pane|
    {
      handlers.push(Uuid().toStr)
      Actor.locals[handlers.peek] = pane
    }
    sqlEditPaneHandlers = handlers.toImmutable
  }

  override Obj? receive(Obj? msg)
  {

    if(watcher.check())
    {
      info("Updating SqlPackageEditPane")
      Desktop.callAsync |->|
      {
        updatePane
      }
    }
    sendLater(10ms, null)
    return null
  }

  Void updatePane()
  {
    sqlEditPaneHandlers .each |handle|
    {
      pane := Actor.locals[handle] as SqlPackageEditPane
      if(pane!=null)
      {
        pane.notifyChange()
      }
    }
  }
}
